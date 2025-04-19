from fastapi import APIRouter, Depends
from pydantic import BaseModel
from utils.jwt import get_current_user
from controllers.reports import (
    add_a_report, get_all_reports, get_report_by_id,
    edit_report, delete_report as delete_report_controller
)



reports_router = APIRouter(prefix="/api")

from pydantic import BaseModel

class ReportBase(BaseModel):
    title: str
    description: str
    location: str
    status: str


@reports_router.post("/report")
def add_report(payload: ReportBase, current_user: dict = Depends(get_current_user)):
    return add_a_report(
        payload.title,
        payload.description,
        payload.location,
        payload.status,
        current_user["user_id"]
    )

@reports_router.get("/report")
def get_reports():
    return get_all_reports()

@reports_router.get("/report/{report_id}")
def get_report(report_id: int):
    return get_report_by_id(report_id)

@reports_router.put("/report/{report_id}")
def update_report(report_id: int, payload: ReportBase, current_user: dict = Depends(get_current_user)):
    return edit_report(
        report_id,
        payload.title,
        payload.description,
        payload.location,
        payload.status,
        current_user["user_id"]
    )
@reports_router.delete("/report/{report_id}")
def delete_report(report_id: int, current_user: dict = Depends(get_current_user)):
    return delete_report_controller(report_id, current_user["user_id"])
