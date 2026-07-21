import type { SVGProps } from "react"

const MathBlockIcon = (props: SVGProps<SVGSVGElement>) => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    width="24"
    height="24"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    strokeWidth="2"
    strokeLinecap="round"
    strokeLinejoin="round"
    {...props}
  >
    <path d="m16 16-3 3 3 3" />
    <path d="M3 12h14.5a1 1 0 0 1 0 7H13" />
    <path d="M3 19h6" />
    <path d="M3 5h18" />
  </svg>
)

export { MathBlockIcon }
