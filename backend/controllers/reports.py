from fastapi import HTTPException, status
from db import get_db_connection

def add_a_report(title: str, description: str, location: str, status: str, user_id: str):
    with get_db_connection() as conn:
        cur = conn.cursor()
        cur.execute("""
            INSERT INTO reports (title, description, location, status, user_id)
            VALUES (%s, %s, %s, %s, %s) RETURNING id;
        """, (title, description, location, status, user_id))
        report_id = cur.fetchone()[0]
        conn.commit()
        return {
            "status": "success",
            "message": "Report added successfully",
            "report_id": report_id
        }
        
        
def get_all_reports():
    with get_db_connection() as conn:
        cur = conn.cursor()
        # Updated SQL query to join reports and users tables
        cur.execute("""
            SELECT reports.id, reports.title, reports.description, reports.location, 
                   reports.status, reports.user_id, users.email 
            FROM reports 
            JOIN users ON reports.user_id = users.id
        """)
        all_reports = cur.fetchall()

        reports = []
        for report in all_reports:
            reports.append({
                'id' : report[0],
                'title': report[1],
                'description': report[2],
                'location': report[3],
                'status': report[4],
                'user_id': report[5],
                'email': report[6]
            })

        return {
            "status": "success",
            "fetched_all": reports
        }

def get_report_by_id(report_id: int):
    with get_db_connection() as conn:
        cur = conn.cursor()
        cur.execute("SELECT * FROM reports WHERE id = %s", (report_id,))
        report = cur.fetchone()
        if not report:
            raise HTTPException(status_code=404, detail="Report not found")
        return {
            "status": "success",
            "report": report
        }
def edit_report(report_id: int, title: str, description: str, location: str, status: str, current_user_id: str):
    with get_db_connection() as conn:
        cur = conn.cursor()
        cur.execute("SELECT user_id FROM reports WHERE id = %s", (report_id,))
        report = cur.fetchone()
        if not report:
            raise HTTPException(status_code=404, detail="Report not found")
        
        report_owner_id = report[0]
        if report_owner_id != current_user_id:
            raise HTTPException(status_code=403, detail="Not authorized to edit this report")
        
        cur.execute("""
            UPDATE reports
            SET title = %s, description = %s, location = %s, status = %s
            WHERE id = %s
        """, (title, description, location, status, report_id))
        conn.commit()
        
        return {
            "status": "success",
            "message": "Report updated successfully"
        }
        
        
        
def delete_report(report_id: int, current_user_id: str):
    with get_db_connection() as conn:
        cur = conn.cursor()
        cur.execute("SELECT user_id FROM reports WHERE id = %s", (report_id,))
        report = cur.fetchone()
        if not report:
            raise HTTPException(status_code=404, detail="Report not found")
        
        report_owner_id = report[0]
        if report_owner_id != current_user_id:
            raise HTTPException(status_code=403, detail="Not authorized to delete this report")
        
        cur.execute("DELETE FROM reports WHERE id = %s", (report_id,))
        conn.commit()
        
        return {
            "status": "success",
            "message": "Report deleted successfully"
        }

def user_reports(current_user_id: str):
    with get_db_connection() as conn:
        cur = conn.cursor()
        cur.execute("""
            SELECT reports.id, reports.title, reports.description, reports.location, 
                   reports.status, reports.user_id, users.email 
            FROM reports
            JOIN users ON reports.user_id = users.id
            WHERE reports.user_id = %s
        """, (current_user_id,))
        rows = cur.fetchall()

        columns = [desc[0] for desc in cur.description]
        reports = [dict(zip(columns, row)) for row in rows]

    return {
        "user_reports": reports
    }
