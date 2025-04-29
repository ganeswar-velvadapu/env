from fastapi import APIRouter, Depends
from utils.jwt import get_current_user
from pydantic import BaseModel
from controllers.events import create_event, all_events, edit_event,delete_a_event, ngo_events

events_router = APIRouter(prefix="/api")


class Event(BaseModel):
    title:str
    description:str
    location:str
    

@events_router.get("/events")
def get_all_events():
    return all_events()
    

@events_router.post("/events")
def add_event(payload: Event, current_user=Depends(get_current_user)):
    return create_event(
        payload.title,
        payload.description,
        payload.location,
        current_user["user_id"],
        current_user["user_type"]
    )

@events_router.put("/events/{event_id}")
def update_event(event_id: int, payload: Event, current_user: dict = Depends(get_current_user)):
    return edit_event(
        event_id,
        payload.title,
        payload.description,
        payload.location,
        current_user["user_id"],
        current_user["user_type"]
    )

@events_router.delete("/events/{event_id}")
def delete_event(event_id:int,current_user: dict = Depends(get_current_user)):
    return delete_a_event(event_id, current_user["user_id"])


@events_router.get("/ngo/events")
def get_ngo_report(current_user:dict= Depends(get_current_user)):
    return ngo_events(current_user_id=current_user["user_id"])