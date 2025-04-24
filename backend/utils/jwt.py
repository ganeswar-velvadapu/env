from jose import jwt, JWTError
from fastapi import Depends, HTTPException,status
from datetime import datetime, timedelta
from fastapi.security import OAuth2PasswordBearer
from dotenv import load_dotenv
import os

load_dotenv()

jwt_secret = os.getenv("JWT_SECRET")


oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")

SECRET_KEY=jwt_secret
ALGORITHM="HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60

def create_access_token(data : dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


def decode_jwt(token:str):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token"
        )
   
   
def get_current_user(token: str = Depends(oauth2_scheme)):
    payload = decode_jwt(token)
    user_id = payload.get("user_id")
    if not user_id:
        raise HTTPException(status_code=401, detail="User ID not found in token")
    return payload  