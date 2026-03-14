import 'package:flutter/material.dart';
import '../services/agent_service.dart';

// ---------------------------------------------------------------------------
// Pipeline stage definitions (order, icon, colour)
// ---------------------------------------------------------------------------

class _StageConfig {
  final AgentPipelineStage stage;
  final String label;
  final String agentName;
  final IconData icon;
  final Color color;

  const _StageConfig({
    required this.stage,
    required this.label,
    required this.agentName,
    required this.icon,
    required this.color,
  });
}

const List<_StageConfig> _stages = [
  _StageConfig(
    stage: AgentPipelineStage.retrieving,
    label: 'Retrieving',
    agentName: 'Law Retrieval Agent',
    icon: Icons.search_rounded,
    color: Color(0xFF1565C0),
  ),
  _StageConfig(
    stage: AgentPipelineStage.explaining,
    label: 'Explaining',
    agentName: 'Explanation Agent',
    icon: Icons.auto_stories_rounded,
    color: Color(0xFF6A1B9A),
  ),
  _StageConfig(
    stage: AgentPipelineStage.guiding,
    label: 'Guidance',
    agentName: 'Guidance Agent',
    icon: Icons.route_rounded,
    color: Color(0xFF00401A),
  ),
];

// ---------------------------------------------------------------------------
// AgentStatusWidget
// ---------------------------------------------------------------------------

/// Displays the real-time progress of the three-agent pipeline.
///
/// Renders each agent as an animated stage tile.  The active stage pulses
/// with a shimmer animation; completed stages show a solid check; pending
/// stages are greyed out.
class AgentStatusWidget extends StatefulWidget {
  /// Current pipeline stage reported by [AgentService].
  final AgentPipelineStage currentStage;

  const AgentStatusWidget({super.key, required this.currentStage});

  @override
  State<AgentStatusWidget> createState() => _AgentStatusWidgetState();
}

class _AgentStatusWidgetState extends State<AgentStatusWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  bool _isCompleted(_StageConfig cfg) {
    final order = _stages.indexWhere((s) => s.stage == cfg.stage);
    final current = _stages.indexWhere((s) => s.stage == widget.currentStage);
    if (widget.currentStage == AgentPipelineStage.done) return true;
    return order < current;
  }

  bool _isActive(_StageConfig cfg) => widget.currentStage == cfg.stage;

  @override
  Widget build(BuildContext context) {
    final isDone = widget.currentStage == AgentPipelineStage.done;
    final isError = widget.currentStage == AgentPipelineStage.error;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isError
              ? const Color(0xFFF44336).withOpacity(0.4)
              : const Color(0xFF00401A).withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isError
                      ? const Color(0xFFF44336).withOpacity(0.12)
                      : const Color(0xFF00401A).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isError
                      ? Icons.error_outline_rounded
                      : Icons.smart_toy_rounded,
                  size: 18,
                  color: isError
                      ? const Color(0xFFF44336)
                      : const Color(0xFF00401A),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isError
                          ? 'Agent Pipeline Error'
                          : isDone
                          ? 'Agents Completed'
                          : 'AI Agents Active',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF00401A),
                        letterSpacing: 0.2,
                      ),
                    ),
                    Text(
                      isError
                          ? 'One or more agents encountered an error'
                          : isDone
                          ? 'All three agents finished successfully'
                          : widget.currentStage.description,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ---- Pipeline stages row ----------------------------------------
          Row(
            children: List.generate(_stages.length * 2 - 1, (i) {
              // Connector lines between stages
              if (i.isOdd) {
                final leftIdx = (i - 1) ~/ 2;
                final leftDone = _isCompleted(_stages[leftIdx]) || (isDone);
                return Expanded(
                  child: Container(
                    height: 2,
                    color: leftDone
                        ? const Color(0xFF00401A).withOpacity(0.4)
                        : Colors.grey.shade200,
                  ),
                );
              }

              final idx = i ~/ 2;
              final cfg = _stages[idx];
              final done = _isCompleted(cfg);
              final active = _isActive(cfg);

              return _StagePill(
                config: cfg,
                isActive: active,
                isCompleted: done,
                isError: isError && active,
                pulseAnimation: _pulseAnimation,
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Individual stage pill
// ---------------------------------------------------------------------------

class _StagePill extends StatelessWidget {
  final _StageConfig config;
  final bool isActive;
  final bool isCompleted;
  final bool isError;
  final Animation<double> pulseAnimation;

  const _StagePill({
    required this.config,
    required this.isActive,
    required this.isCompleted,
    required this.isError,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = isError ? const Color(0xFFF44336) : config.color;

    final Color bgColor = isCompleted || isActive
        ? activeColor.withOpacity(isActive ? 0.12 : 0.08)
        : Colors.grey.shade100;

    final Color iconColor = isCompleted || isActive
        ? activeColor
        : Colors.grey.shade400;

    Widget iconWidget = Icon(
      isCompleted ? Icons.check_circle_rounded : config.icon,
      size: 18,
      color: iconColor,
    );

    if (isActive && !isError) {
      iconWidget = AnimatedBuilder(
        animation: pulseAnimation,
        builder: (_, child) =>
            Opacity(opacity: pulseAnimation.value, child: child),
        child: iconWidget,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: isActive
                ? Border.all(color: activeColor, width: 2)
                : Border.all(
                    color: isCompleted
                        ? activeColor.withOpacity(0.3)
                        : Colors.grey.shade200,
                  ),
          ),
          child: Center(child: iconWidget),
        ),
        const SizedBox(height: 6),
        Text(
          config.label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive || isCompleted ? activeColor : Colors.grey.shade400,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          config.agentName,
          style: TextStyle(fontSize: 9, color: Colors.grey.shade400),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// AgentModeToggle — compact chip for the chat input bar
// ---------------------------------------------------------------------------

/// A small toggleable chip that sits in the chat input area and switches
/// the chat screen between standard RAG mode and the multi-agent pipeline.
class AgentModeToggle extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onToggle;

  const AgentModeToggle({
    super.key,
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isEnabled ? const Color(0xFF00401A) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isEnabled ? const Color(0xFF00401A) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.smart_toy_rounded,
              size: 14,
              color: isEnabled ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 5),
            Text(
              isEnabled ? 'Agents ON' : 'Agents',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isEnabled ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// AgentResponseCard — rich structured response display
// ---------------------------------------------------------------------------

/// Renders a full [AgentResponse] as an expandable card with sections for
/// key points, procedures, required documents, and official links.
class AgentResponseCard extends StatefulWidget {
  final String summary;
  final List<String> keyPoints;
  final List<Map<String, dynamic>> steps;
  final List<String> requiredDocuments;
  final Map<String, String> officialLinks;
  final String? notes;
  final double elapsedSeconds;

  const AgentResponseCard({
    super.key,
    required this.summary,
    required this.keyPoints,
    required this.steps,
    required this.requiredDocuments,
    required this.officialLinks,
    this.notes,
    required this.elapsedSeconds,
  });

  @override
  State<AgentResponseCard> createState() => _AgentResponseCardState();
}

class _AgentResponseCardState extends State<AgentResponseCard> {
  bool _showSteps = true;
  bool _showKeyPoints = false;
  bool _showDocs = false;
  bool _showLinks = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- Agent badge --------------------------------------------------
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF00401A).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.smart_toy_rounded,
                    size: 12,
                    color: Color(0xFF00401A),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Agent Pipeline',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF00401A),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.elapsedSeconds.toStringAsFixed(1)}s',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // ---- Summary ------------------------------------------------------
        Text(
          widget.summary,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.5,
          ),
        ),

        if (widget.notes != null && widget.notes!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFFF9800).withOpacity(0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: Color(0xFFE65100),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.notes!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFE65100),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 12),

        // ---- Expandable sections ------------------------------------------
        if (widget.steps.isNotEmpty)
          _Section(
            icon: Icons.route_rounded,
            color: const Color(0xFF00401A),
            title: 'Step-by-Step Guidance',
            count: widget.steps.length,
            isOpen: _showSteps,
            onToggle: () => setState(() => _showSteps = !_showSteps),
            child: _StepsList(steps: widget.steps),
          ),

        if (widget.keyPoints.isNotEmpty)
          _Section(
            icon: Icons.lightbulb_outline_rounded,
            color: const Color(0xFF6A1B9A),
            title: 'Key Legal Points',
            count: widget.keyPoints.length,
            isOpen: _showKeyPoints,
            onToggle: () => setState(() => _showKeyPoints = !_showKeyPoints),
            child: _BulletList(
              items: widget.keyPoints,
              bulletColor: const Color(0xFF6A1B9A),
            ),
          ),

        if (widget.requiredDocuments.isNotEmpty)
          _Section(
            icon: Icons.description_outlined,
            color: const Color(0xFF1565C0),
            title: 'Required Documents',
            count: widget.requiredDocuments.length,
            isOpen: _showDocs,
            onToggle: () => setState(() => _showDocs = !_showDocs),
            child: _BulletList(
              items: widget.requiredDocuments,
              bulletColor: const Color(0xFF1565C0),
            ),
          ),

        if (widget.officialLinks.isNotEmpty)
          _Section(
            icon: Icons.open_in_new_rounded,
            color: const Color(0xFF00838F),
            title: 'Official Links',
            count: widget.officialLinks.length,
            isOpen: _showLinks,
            onToggle: () => setState(() => _showLinks = !_showLinks),
            child: _LinksList(links: widget.officialLinks),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets for AgentResponseCard
// ---------------------------------------------------------------------------

class _Section extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final int count;
  final bool isOpen;
  final VoidCallback onToggle;
  final Widget child;

  const _Section({
    required this.icon,
    required this.color,
    required this.title,
    required this.count,
    required this.isOpen,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          // Header tap
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: color.withOpacity(0.7),
                  ),
                ],
              ),
            ),
          ),
          // Body
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            firstCurve: Curves.easeOut,
            secondCurve: Curves.easeIn,
            crossFadeState: isOpen
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: child,
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _StepsList extends StatelessWidget {
  final List<Map<String, dynamic>> steps;
  const _StepsList({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: steps.map((step) {
        final num = step['step_number'] ?? 0;
        final title = step['title'] as String? ?? '';
        final desc = step['description'] as String? ?? '';
        final tips = step['tips'] as String?;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF00401A),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$num',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                    if (tips != null && tips.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.tips_and_updates_rounded,
                            size: 12,
                            color: Color(0xFFFF9800),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              tips,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFE65100),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _BulletList extends StatelessWidget {
  final List<String> items;
  final Color bulletColor;
  const _BulletList({required this.items, required this.bulletColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 5),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: bulletColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _LinksList extends StatelessWidget {
  final Map<String, String> links;
  const _LinksList({required this.links});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: links.entries.map((e) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.link_rounded,
                size: 14,
                color: Color(0xFF00838F),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.key,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      e.value,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF00838F),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
