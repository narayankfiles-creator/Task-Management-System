from fastapi import FastAPI, Depends, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import create_engine, Column, Integer, String, Date, Enum as SQLEnum, ForeignKey
from sqlalchemy.orm import declarative_base, sessionmaker, Session
from pydantic import BaseModel, Field
from typing import List, Optional
import enum
import datetime
import asyncio

# --- Database Setup ---
# We are using SQLite for easy local setup without needing external database servers.
SQLALCHEMY_DATABASE_URL = "sqlite:///./tasks.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# --- Models (SQLAlchemy) ---
class TaskStatus(str, enum.Enum):
    TODO = "To-Do"
    IN_PROGRESS = "In Progress"
    DONE = "Done"

class DBTask(Base):
    __tablename__ = "tasks"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    description = Column(String)
    due_date = Column(Date)
    status = Column(SQLEnum(TaskStatus), default=TaskStatus.TODO)
    # Self-referential foreign key for the "Blocked By" feature
    blocked_by_id = Column(Integer, ForeignKey("tasks.id"), nullable=True)

# Create the database tables on startup
Base.metadata.create_all(bind=engine)

# --- Pydantic Schemas (Data Validation) ---
class TaskBase(BaseModel):
    title: str
    description: str
    due_date: datetime.date
    status: TaskStatus = TaskStatus.TODO
    blocked_by_id: Optional[int] = None

class TaskCreate(TaskBase):
    pass

class TaskUpdate(TaskBase):
    pass

class TaskResponse(TaskBase):
    id: int

    class Config:
        from_attributes = True # Required for Pydantic V2 to read SQLAlchemy models

# --- Dependency ---
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# --- FastAPI App & Endpoints ---
app = FastAPI(title="Flodo Task API")

# --- CORS CONFIGURATION ---
# This allows your Flutter web app (running on a different port) to talk to this API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # Allows all web origins to connect
    allow_credentials=True,
    allow_methods=["*"], # Allows POST, GET, PUT, DELETE
    allow_headers=["*"],
)

@app.get("/tasks/", response_model=List[TaskResponse])
def get_tasks(
    search: Optional[str] = None,
    status: Optional[TaskStatus] = None,
    db: Session = Depends(get_db)
):
    """Fetch all tasks. Supports filtering by status and searching by title."""
    query = db.query(DBTask)
    
    if search:
        query = query.filter(DBTask.title.ilike(f"%{search}%"))
    if status:
        query = query.filter(DBTask.status == status)
        
    return query.all()

@app.get("/tasks/{task_id}", response_model=TaskResponse)
def get_task(task_id: int, db: Session = Depends(get_db)):
    """Fetch a single task by ID."""
    task = db.query(DBTask).filter(DBTask.id == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    return task

@app.post("/tasks/", response_model=TaskResponse)
async def create_task(task: TaskCreate, db: Session = Depends(get_db)):
    """Create a task with an artificial 2-second delay."""
    
    # Requirement: 2-second artificial delay
    await asyncio.sleep(2)
    
    # Validation: Check if the blocking task actually exists
    if task.blocked_by_id:
        blocking_task = db.query(DBTask).filter(DBTask.id == task.blocked_by_id).first()
        if not blocking_task:
            raise HTTPException(status_code=400, detail="Blocking task not found")

    db_task = DBTask(**task.model_dump())
    db.add(db_task)
    db.commit()
    db.refresh(db_task)
    return db_task

@app.put("/tasks/{task_id}", response_model=TaskResponse)
async def update_task(task_id: int, task: TaskUpdate, db: Session = Depends(get_db)):
    """Update a task with an artificial 2-second delay."""
    
    # Requirement: 2-second artificial delay
    await asyncio.sleep(2)

    db_task = db.query(DBTask).filter(DBTask.id == task_id).first()
    if not db_task:
        raise HTTPException(status_code=404, detail="Task not found")
        
    # Validation: Prevent a task from blocking itself
    if task.blocked_by_id == task_id:
        raise HTTPException(status_code=400, detail="A task cannot block itself")

    # Validation: Check if the blocking task actually exists
    if task.blocked_by_id:
        blocking_task = db.query(DBTask).filter(DBTask.id == task.blocked_by_id).first()
        if not blocking_task:
            raise HTTPException(status_code=400, detail="Blocking task not found")

    # Update fields
    for key, value in task.model_dump().items():
        setattr(db_task, key, value)
    
    db.commit()
    db.refresh(db_task)
    return db_task

@app.delete("/tasks/{task_id}")
def delete_task(task_id: int, db: Session = Depends(get_db)):
    """Delete a task by ID."""
    db_task = db.query(DBTask).filter(DBTask.id == task_id).first()
    if not db_task:
        raise HTTPException(status_code=404, detail="Task not found")
        
    db.delete(db_task)
    db.commit()
    return {"message": "Task deleted successfully"}