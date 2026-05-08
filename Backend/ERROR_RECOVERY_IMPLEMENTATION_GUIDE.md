"""
ERROR_RECOVERY_PATCH.md

This document outlines the critical error recovery improvements needed in agent_orchestrator.py

Current Problem:
- Any agent failure (retrieval, verification, explanation, guidance) raises OrchestratorError
- This causes the entire pipeline to fail
- Users get "Guidance encountered an unexpected error" instead of partial results

Solution: Graceful Degradation
- Each agent should return minimal valid output if it fails
- Pipeline continues even if one agent fails
- Users always get some answer (degraded quality if necessary)

Implementation Changes:

1. RETRIEVAL ERROR RECOVERY
   Current:
     try:
         raw_chunks = await run_law_retrieval_agent(...)
     except LawRetrievalError as exc:
         raise OrchestratorError(f"Retrieval failed: {exc}") from exc
   
   Fixed:
     try:
         raw_chunks = await run_law_retrieval_agent(...)
     except Exception as exc:
         logger.warning("[Orchestrator] Retrieval failed: %s — using Groq knowledge", exc)
         raw_chunks = []  # Empty chunks - continue to next stage
         # Mark that retrieval failed in response notes


2. VERIFICATION ERROR RECOVERY
   Current:
     except Exception as exc:
         logger.exception("[Orchestrator] Verification error: %s — using all raw chunks", exc)
         from verification_agent import VerifiedChunk, VerificationReport as VR
         report = VR(verified=[], discarded=[], overall_confidence=0.5, last_updated=None)
   
   Fixed: (Already good) - continues with degraded confidence


3. EXPLANATION ERROR RECOVERY
   Current:
     except ExplanationError as exc:
         raise OrchestratorError(f"Explanation failed: {exc}") from exc
   
   Fixed:
     except Exception as exc:
         logger.warning("[Orchestrator] Explanation failed: %s — using raw content", exc)
         from explanation_agent import ExplanationOutput
         explanation = ExplanationOutput(
             summary=f"Unable to generate explanation. Raw information: {', '.join([c.get('title', '')[:50] for c in verified_dicts[:3]])}",
             key_points=["See raw documents below for details"],
             references={},
         )


4. GUIDANCE ERROR RECOVERY
   Current:
     except GuidanceError as exc:
         raise OrchestratorError(f"Guidance failed: {exc}") from exc
   
   Fixed:
     except Exception as exc:
         logger.warning("[Orchestrator] Guidance failed: %s — using default steps", exc)
         from guidance_agent import GuidanceOutput, GuidanceStep
         guidance = GuidanceOutput(
             steps=[
                 GuidanceStep(
                     step_number=1,
                     title="Review Available Information",
                     description="Consult the documents and key points provided above for details on your legal matter.",
                     tips="Write down important steps as you read through the materials."
                 ),
                 GuidanceStep(
                     step_number=2,
                     title="Seek Professional Guidance",
                     description="Consult with a qualified lawyer or relevant government department for official guidance.",
                     tips="Take this information with you to your consultation."
                 )
             ],
             required_documents=["Legal documents relevant to your case"],
             official_links=official_links_hint or {},
             notes="Procedural steps could not be auto-generated. Please follow the steps above."
         )


5. ADD METRICS TRACKING
   After each agent stage, log:
   - Agent name
   - Execution time
   - Success/failure status
   - Error message (if failed)
   
   Example:
     stage_start = time.monotonic()
     try:
         raw_chunks = await run_law_retrieval_agent(...)
         stage_elapsed = time.monotonic() - stage_start
         logger.info(f"[METRICS] law_retrieval_agent: {stage_elapsed:.3f}s SUCCESS")
     except Exception as exc:
         stage_elapsed = time.monotonic() - stage_start
         logger.warning(f"[METRICS] law_retrieval_agent: {stage_elapsed:.3f}s FAILED - {str(exc)[:100]}")
         raw_chunks = []


6. COLLECT METRICS FOR DB
   Create dict to track all metrics:
   
     metrics = {
         "law_retrieval_ms": law_retrieval_time * 1000,
         "verification_ms": verification_time * 1000,
         "explanation_ms": explanation_time * 1000,
         "guidance_ms": guidance_time * 1000,
         "total_ms": total_time * 1000,
         "success": all_stages_succeeded,
         "error_stage": stage_that_failed or None,
         "error_message": error_msg or None,
     }
   
   Return metrics with OrchestratorResponse for backend to store in DB

---

IMPLEMENTATION CHECKLIST:

[ ] Add stage timing for each agent
[ ] Add try/except with graceful fallback for each agent
[ ] Create fallback explanation, guidance, steps
[ ] Track metrics dict with timing and error info
[ ] Save metrics to agent_metrics Supabase table
[ ] Test each failure mode:
    - Retrieval fails → empty chunks
    - Verification fails → unverified chunks
    - Explanation fails → fallback text
    - Guidance fails → default steps
[ ] Verify response quality degrades gracefully
[ ] Add telemetry logging for monitoring
"""
