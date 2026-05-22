import { LoginButton } from "@/components/auth/login-button"

export default function LoginPage() {
  return (
    <main className="flex min-h-dvh items-center justify-center">
      <div className="flex flex-col items-center gap-4">
        <h1 className="mb-3 font-heading text-4xl">تسجيل الدخول</h1>
        <LoginButton />
      </div>
    </main>
  )
}
