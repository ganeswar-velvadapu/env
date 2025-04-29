from fastapi import HTTPException, status
from db import get_db_connection



def create_event(title:str,description:str,location:str,ngo_id:str,user_type:str):
    with get_db_connection() as conn:
        cur = conn.cursor()
        if(user_type != "ngo"):
            raise HTTPException(status_code=401,detail="You are not authorized to add an event")
        cur.execute("""
            INSERT INTO events (title, description, location, ngo_id)
            VALUES (%s, %s, %s, %s) RETURNING id;
        """, (title, description, location, ngo_id))
        event_id = cur.fetchone()[0]
        
        conn.commit()
        return {
            "status" : "success",
            "message" : "Event added succesfully",
            "event_id" : event_id
        }
        
def all_events():
    with get_db_connection() as conn:
        cur = conn.cursor()
        cur.execute("""
                        SELECT events.id, events.title, events.description, events.location, 
                    events.ngo_id, users.email 
            FROM events 
            JOIN users ON events.ngo_id = users.id
                    """)
        all_events = cur.fetchall()
        events = []
        for event in all_events:
            events.append({
                'id' : event[0],
                'title': event[1],
                'description': event[2],
                'location': event[3],
                'ngo_id': event[4],
                'email': event[5]
            })
            
        return {
            "status": "success",
            "all_events": events
        }

def edit_event(event_id: int, title: str, description: str, location: str, ngo_id: str, user_type: str):
    if user_type != "ngo":
        raise HTTPException(status_code=403, detail="Only NGO users can edit events.")

    with get_db_connection() as conn:
        cur = conn.cursor()

        cur.execute("SELECT ngo_id FROM events WHERE id = %s;", (event_id,))
        result = cur.fetchone()

        if not result:
            raise HTTPException(status_code=404, detail="Event not found.")

        event_owner_id = result[0]
        if str(event_owner_id) != str(ngo_id):
            raise HTTPException(status_code=403, detail="You do not have permission to edit this event.")
        cur.execute("""
            UPDATE events 
            SET title = %s, description = %s, location = %s 
            WHERE id = %s;
        """, (title, description, location, event_id))

        conn.commit()

        return {
            "status": "success",
            "message": "Event updated successfully."
        }
        
def delete_a_event(event_id:int,ngo_id:int):
    with get_db_connection() as conn:
        cur = conn.cursor()
        cur.execute("SELECT ngo_id FROM events WHERE id = %s", (event_id,))
        report = cur.fetchone()
        if not report:
            raise HTTPException(status_code=404, detail="Event not found")
        
        events_owner_id = report[0]
        if events_owner_id != ngo_id:
            raise HTTPException(status_code=403, detail="Not authorized to delete this event")
        cur.execute("DELETE FROM events WHERE id = %s", (event_id,))
        conn.commit()
        
        return {
            "status": "success",
            "message": "Event deleted successfully"
        }
        
        
def ngo_events(current_user_id: str):
    with get_db_connection() as conn:
        cur = conn.cursor()
        cur.execute("""
            SELECT events.id, events.title, events.description, events.location,
                   events.ngo_id, users.email
            FROM events
            JOIN users ON events.ngo_id = users.id
            WHERE events.ngo_id = %s
        """, (current_user_id,))
        rows = cur.fetchall()

        columns = [desc[0] for desc in cur.description]
        events = [dict(zip(columns, row)) for row in rows]

    return {
        "ngo_events": events
    }
