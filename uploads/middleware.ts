import { type NextRequest, NextResponse } from "next/server";
import { updateSession } from "@/utils/supabase/middleware";

export async function middleware(request: NextRequest) {
  // Refresh session
  const response = await updateSession(request);

  // Protect /portal routes
  if (request.nextUrl.pathname.startsWith("/portal")) {
    // Check if user is authenticated by checking for auth cookie
    const authToken = request.cookies.get("sb-auth-token");

    if (!authToken) {
      // Redirect to login if no auth token
      const loginUrl = new URL("/login", request.url);
      return NextResponse.redirect(loginUrl);
    }
  }

  return response;
}

export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     */
    "/((?!_next/static|_next/image|favicon.ico).*)",
  ],
};
