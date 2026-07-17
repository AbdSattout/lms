import type { SVGProps } from "react"

const SigmaIcon = (props: SVGProps<SVGSVGElement>) => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 24 24"
    width="24"
    height="24"
    fill="none"
    stroke="currentColor"
    strokeWidth="2"
    strokeLinecap="round"
    strokeLinejoin="round"
    {...props}
  >
    <path d="M18 7V5a1 1 0 0 0-1-1H6.5a.5.5 0 0 0-.4.8l5.6 7.2a1 1 0 0 1 0 1.2l-5.6 7.2a.5.5 0 0 0 .4.8H17a1 1 0 0 0 1-1v-2" />
  </svg>
)

export { SigmaIcon }
