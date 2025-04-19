from fastapi import HTTPException, status
from db import get_db_connection
import bcrypt
from utils.jwt import create_access_token


def register_user(email: str, password: str, user_type: str = "normal"):
    hashed_pw = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())

    with get_db_connection() as conn:
        cur = conn.cursor()
        cur.execute("SELECT id FROM users WHERE email = %s", (email,))
        if cur.fetchone():
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email already registered"
            )

        cur.execute("""
            INSERT INTO users (email, password, user_type)
            VALUES (%s, %s, %s)
            RETURNING id, email, user_type;
        """, (email, hashed_pw.decode('utf-8'), user_type))

        user = cur.fetchone()
        conn.commit()

        token = create_access_token({
            "user_id": user[0],
            "user_type": user[2]
        })

        return {
            "status": "success",
            "message": "User registered successfully",
            "data": {
                "id": user[0],
                "email": user[1],
                "user_type": user[2],
                "token": token
            }
        }


def login_user(email: str, password: str):
    with get_db_connection() as conn:
        cur = conn.cursor()
        cur.execute("SELECT id, password, user_type FROM users WHERE email = %s", (email,))
        user = cur.fetchone()

        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )

        user_id, hashed_pw, user_type = user

        if not bcrypt.checkpw(password.encode('utf-8'), hashed_pw.encode('utf-8')):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid credentials"
            )
        token = create_access_token({
            "user_id": user_id,
            "user_type": user_type
        })

        return {
            "status": "success",
            "message": "Login successful",
            "data": {
                "id": user_id,
                "email": email,
                "user_type": user_type,
                "token": token
            }
        }
