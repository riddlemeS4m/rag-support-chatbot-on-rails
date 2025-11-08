# QuantHub Support Chatbot

RAG-powered support chatbot using pgvector and OpenAI.

## Setup

1. Install dependencies:
```bash
   bundle install
```

2. Setup database:
```bash
   rails db:create db:migrate
```

3. Add API key to `.env`:
```
   OPENAI_API_KEY=sk-...
```

4. Sync articles:
```bash
   rails articles:sync
```

5. Start server:
```bash
   rails server
```

## API Usage
```bash
curl -X POST http://localhost:3000/api/v1/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "your question here"}'
```

## Updating Articles

Re-run the sync to update articles:
```bash
rails articles:sync
```