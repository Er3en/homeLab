from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional

app = FastAPI(title="Simple REST API - No Database")

# In-memory storage for testing
users_db = []
next_user_id = 1

class User(BaseModel):
    name: str
    email: str

class UserResponse(BaseModel):
    id: int
    name: str
    email: str

def find_user_by_id(user_id: int) -> Optional[dict]:
    return next((user for user in users_db if user["id"] == user_id), None)

def find_user_by_email(email: str) -> Optional[dict]:
    return next((user for user in users_db if user["email"] == email), None)

@app.get("/")
def read_root():
    return {"message": "Simple FastAPI REST Server - No Database", "total_users": len(users_db)}

@app.get("/health")
def health_check():
    return {"status": "healthy", "service": "fastapi-rest-api"}

@app.get("/users", response_model=List[UserResponse])
def get_users():
    return users_db

@app.get("/users/{user_id}", response_model=UserResponse)
def get_user(user_id: int):
    user = find_user_by_id(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@app.post("/users", response_model=UserResponse)
def create_user(user: User):
    global next_user_id

    if find_user_by_email(user.email):
        raise HTTPException(status_code=400, detail="Email already exists")
    
    new_user = {
        "id": next_user_id,
        "name": user.name,
        "email": user.email
    }
    users_db.append(new_user)
    next_user_id += 1

    return new_user

@app.put("/users/{user_id}", response_model=UserResponse)
def update_user(user_id: int, user: User):
    existing_user = find_user_by_id(user_id)
    if not existing_user:
        raise HTTPException(status_code=404, detail="User not found")

    email_user = find_user_by_email(user.email)
    if email_user and email_user["id"] != user_id:
        raise HTTPException(status_code=400, detail="Email already exists")

    existing_user["name"] = user.name
    existing_user["email"] = user.email
    return existing_user

@app.delete("/users/{user_id}")
def delete_user(user_id: int):
    for i, user in enumerate(users_db):
        if user["id"] == user_id:
            deleted_user = users_db.pop(i)
            return {"message": "User deleted successfully", "deleted_user": deleted_user}
    
    raise HTTPException(status_code=404, detail="User not found")

@app.get("/stats")
def get_stats():
    return {
        "total_users": len(users_db),
        "api_version": "1.0.0",
        "database_type": "in-memory"
    }
