export interface BackendUser {
  id: number
  name: string
  picture?: string | null
}

export interface BackendAuthLoginResponse {
  token: string
  user: BackendUser
}
