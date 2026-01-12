from fastapi import FastAPI

app = FastAPI(title="TFT Comp Suggester")

@app.get("/health")
def health():
    return {"status": "ok"}
