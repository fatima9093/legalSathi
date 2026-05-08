-- Add status field to complaints table (if not already exists)
ALTER TABLE complaints
ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'submitted',
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;

-- Create complaint_status_history table
CREATE TABLE IF NOT EXISTS complaint_status_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    complaint_id UUID NOT NULL REFERENCES complaints(complaint_id) ON DELETE CASCADE,
    status VARCHAR(50) NOT NULL,
    changed_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    notes TEXT,
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_complaint_status ON complaints(status);
CREATE INDEX IF NOT EXISTS idx_complaint_status_history_complaint_id 
    ON complaint_status_history(complaint_id);
CREATE INDEX IF NOT EXISTS idx_complaint_status_history_changed_at 
    ON complaint_status_history(changed_at DESC);

-- Enable RLS
ALTER TABLE complaint_status_history ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can view status history for their own complaints
CREATE POLICY "Users can view status history for own complaints"
    ON complaint_status_history
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM complaints 
            WHERE complaints.complaint_id = complaint_status_history.complaint_id
            AND complaints.user_id = auth.uid()
        )
    );

-- RLS Policy: Service role can insert status history
CREATE POLICY "Service can insert status history"
    ON complaint_status_history
    FOR INSERT
    WITH CHECK (true);

-- Trigger to update complaint updated_at when status changes
CREATE OR REPLACE FUNCTION update_complaint_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE complaints 
    SET updated_at = CURRENT_TIMESTAMP 
    WHERE complaint_id = NEW.complaint_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER complaint_status_history_update_trigger
AFTER INSERT ON complaint_status_history
FOR EACH ROW
EXECUTE FUNCTION update_complaint_updated_at();

-- Insert initial status history for existing complaints
INSERT INTO complaint_status_history (complaint_id, status, changed_at)
SELECT complaint_id, COALESCE(status, 'submitted'), created_at
FROM complaints
WHERE NOT EXISTS (
    SELECT 1 FROM complaint_status_history 
    WHERE complaint_status_history.complaint_id = complaints.complaint_id
)
ON CONFLICT DO NOTHING;
