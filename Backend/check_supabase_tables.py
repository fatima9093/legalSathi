import requests

SUPABASE_URL = 'https://ghwvezmgxpwwfxaeeriy.supabase.co'
ANON_KEY = 'sb_publishable_IXoVDtzHIvggltxy3kJDjw_LujOV3ZQ'

HEADERS = {
    'apikey': ANON_KEY,
    'Authorization': f'Bearer {ANON_KEY}',
    'Accept': 'application/json'
}

TABLES = [
    'profiles', 'blackmail_cases', 'complaints', 'draft_complaints',
    'fia_complaints', 'fake_account_reports', 'evidence_files', 'chat_messages',
    'conversation_sessions', 'activity_logs', 'admin_logs', 'settings',
    'traffic_complaints', 'traffic_police_complaints', 'labour_complaints',
    'labour_wage_records', 'draft_complaints', 'complaint_status_history',
    'user_documents', 'notifications', 'fake_account_reports', 'blackmail_cases'
]

def check_table(table):
    url = f"{SUPABASE_URL}/rest/v1/{table}?select=id&limit=1"
    try:
        r = requests.get(url, headers=HEADERS, timeout=10)
    except Exception as e:
        return table, 'error', str(e)

    # classify
    if r.status_code == 200:
        return table, 'exists-accessible', r.text[:200]
    if r.status_code == 404:
        # likely relation does not exist
        return table, 'missing', r.text[:200]
    if r.status_code in (401, 403):
        return table, 'forbidden', r.text[:200]
    # other responses
    return table, f'status_{r.status_code}', r.text[:400]

if __name__ == '__main__':
    print('Checking Supabase tables using anon key...')
    results = []
    for t in TABLES:
        name, status, info = check_table(t)
        print(f"{name}: {status}")
        results.append((name, status, info))
    # summary
    missing = [r for r in results if r[1] in ('missing', 'error')]
    print('\nSummary:')
    print(f'Total checked: {len(results)}')
    print(f'Missing or error: {len(missing)}')
    for m in missing:
        print('-', m[0], m[1])
