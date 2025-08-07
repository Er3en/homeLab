
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from psycopg2.extras import RealDictCursor
import psycopg2
import uvicorn

app = FastAPI(title="Simple REST API")


def get_db_connection():
    return psycopg2.connect(
        host="", 
        database="postgres", 
        user="postgres", 
        password="",
        port=5432,
        cursor_factory=RealDictCursor
    )


class User(BaseModel):
    name: str
    email: str

def create_table():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            email VARCHAR(100) UNIQUE NOT NULL
        )
    """)
    conn.commit()
    cursor.close()
    conn.close()


@app.get("/")
def read_root():
    return {"message": "Simple FastAPI REST Server"}

@app.get("/users")
def get_users():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM users")
    users = cursor.fetchall()
    cursor.close()
    conn.close()
    return users

@app.get("/users/{user_id}")
def get_user(user_id: int):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))
    user = cursor.fetchone()
    cursor.close()
    conn.close()
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@app.post("/users")
def create_user(user: User):
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        cursor.execute(
            "INSERT INTO users (name, email) VALUES (%s, %s) RETURNING *",
            (user.name, user.email)
        )
        new_user = cursor.fetchone()
        conn.commit()
        cursor.close()
        conn.close()
        return new_user
    except psycopg2.IntegrityError:
        conn.rollback()
        cursor.close()
        conn.close()
        raise HTTPException(status_code=400, detail="Email already exists")

@app.put("/users/{user_id}")
def update_user(user_id: int, user: User):
    conn = get_db_connection()
    cursor = conn.cursor()
    
    cursor.execute(
        "UPDATE users SET name = %s, email = %s WHERE id = %s RETURNING *",
        (user.name, user.email, user_id)
    )
    updated_user = cursor.fetchone()
    conn.commit()
    cursor.close()
    conn.close()
    
    if not updated_user:
        raise HTTPException(status_code=404, detail="User not found")
    return updated_user

@app.delete("/users/{user_id}")
def delete_user(user_id: int):
    conn = get_db_connection()
    cursor = conn.cursor()
    
    cursor.execute("DELETE FROM users WHERE id = %s RETURNING *", (user_id,))
    deleted_user = cursor.fetchone()
    conn.commit()
    cursor.close()
    conn.close()
    
    if not deleted_user:
        raise HTTPException(status_code=404, detail="User not found")
    return {"message": "User deleted successfully"}


if __name__ == "__main__":
    print("Creating database table...")
    create_table()
    print("Starting server...")

    uvicorn.run(app, host="0.0.0.0", port=8000)
