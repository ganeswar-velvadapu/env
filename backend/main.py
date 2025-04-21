from fastapi import FastAPI
from routes.auth import auth_router
from routes.reports import reports_router


app = FastAPI()


app.include_router(auth_router)
app.include_router(reports_router)

@app.get("/")
def home():
    return {
        "message" : "Working"
}