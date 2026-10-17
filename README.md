# ExamForge

Upload a PDF, DOCX, TXT or MD file and get a timed mock test (SSC CGL Tier-2 / UPSC level, 5 options per question), then a score breakdown, weak-topic diagnosis and revision tips.

Stateless by design: nothing is stored on the server, so anyone with the link can upload their own document and test independently.

## Project layout

```
examforge/
├── app.py              Flask backend (extraction, Gemini call, validation)
├── templates/index.html  Tailwind + vanilla JS frontend
├── requirements.txt
├── Procfile            Render / Railway
├── Dockerfile          Hugging Face Spaces / any container host
└── .env.example
```

## Run locally

1. Get a free Gemini API key at https://aistudio.google.com/apikey
2. Set up and start:

```bash
cd examforge
python -m venv .venv
source .venv/bin/activate          # Windows: .venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env               # then paste your key into .env
python app.py
```

3. Open http://localhost:5000

## Configuration (environment variables)

| Variable | Default | Purpose |
|---|---|---|
| `GEMINI_API_KEY` | none (required) | Stays on the server, never sent to the browser |
| `GEMINI_MODEL` | `gemini-2.5-flash` | Any Gemini model that supports JSON output |
| `MAX_UPLOAD_MB` | `15` | Upload size cap |
| `MAX_CHARS` | `90000` | Text sent to the model. Longer documents are sampled evenly across all sections |
| `RATE_LIMIT_PER_HOUR` | `12` | Generations per IP per hour (protects your API quota) |

## Deploy

Push the folder to a GitHub repo first. Always add `GEMINI_API_KEY` as a secret or environment variable in the host's dashboard, never in the code.

**Render**
1. New → Web Service → connect your repo.
2. Build command: `pip install -r requirements.txt`
3. Start command: `gunicorn app:app --timeout 180 --workers 2 --threads 4`
4. Add the `GEMINI_API_KEY` environment variable and deploy. You get a public `https://<name>.onrender.com` URL.

**Railway**
1. New Project → Deploy from GitHub repo. The `Procfile` is detected automatically.
2. Variables tab → add `GEMINI_API_KEY`.
3. Settings → Networking → Generate Domain.

**Hugging Face Spaces**
1. Create a Space and choose **Docker** as the SDK.
2. Upload the project files (the `Dockerfile` listens on port 7860). Add this to the top of `README.md` in the Space:
   ```
   ---
   title: ExamForge
   sdk: docker
   app_port: 7860
   ---
   ```
3. Settings → Variables and secrets → add `GEMINI_API_KEY` as a secret.

## Notes and limits

- Scanned (image-only) PDFs have no text layer. Run OCR first.
- Legacy `.doc` files are not supported. Save as `.docx`.
- Free hosting tiers sleep when idle, so the first load after a pause can take about 30 seconds.
- Generation takes 20 to 60 seconds. The `--timeout 180` flag matters, so keep it on any host you use.
- Answers are sent to the browser with the questions so grading is instant. This is fine for self-study with peers, but not for proctored exams.
