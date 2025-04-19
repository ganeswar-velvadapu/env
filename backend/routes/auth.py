from fastapi import APIRouter
from controllers.auth import register_user, login_user
from pydantic import BaseModel

auth_router = APIRouter(prefix="/api/auth")


class UserLogin(BaseModel):
    email: str
    password: str

class UserRegister(UserLogin):
    user_type: str = "normal"



@auth_router.post("/signup",)
def register(payload: UserRegister):
    return register_user(payload.email, payload.password, payload.user_type)
    
    

@auth_router.post("/login")
def login(payload: UserLogin):
    return login_user(payload.email, payload.password)
