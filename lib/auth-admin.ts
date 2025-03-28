import { getServerSession } from "next-auth";
import { authOptions } from "@/lib";
import { selectAdmin } from "@/daos";

export const isAdmin = async () => {
  const session = await getServerSession(authOptions);
  if (!session?.user) {
    return false;
  }
  const { rows } = await selectAdmin(session.user.email || "");
  if (rows.length === 0) {
    return false;
  }
  return true;
};
