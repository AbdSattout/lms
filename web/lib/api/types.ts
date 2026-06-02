export interface User {
  id: number
  name: string
  picture?: string | null
}

export interface AuthLoginResponse {
  token: string
  user: User
}
