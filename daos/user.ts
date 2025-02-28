import db from "@/lib/db";

export async function selectAdmin(email: string) {
  return db.query("SELECT * FROM admins WHERE email = $1", [email]);
}

export async function selectUser(email: string) {
  return db.query("SELECT * FROM users WHERE email = $1", [email]);
}
