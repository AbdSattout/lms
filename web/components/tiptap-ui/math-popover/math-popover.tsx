"use client"

import { forwardRef, useCallback, useState } from "react"
import type { Editor } from "@tiptap/react"

import { useIsBreakpoint } from "@/hooks/use-is-breakpoint"
import { useTiptapEditor } from "@/hooks/use-tiptap-editor"

import { CornerDownLeftIcon } from "@/components/tiptap-icons/corner-down-left-icon"
import { SigmaIcon } from "@/components/tiptap-icons/sigma-icon"

import type { UseMathPopoverConfig } from "@/components/tiptap-ui/math-popover"
import { useMathPopover, getSelectedMathLatex } from "@/components/tiptap-ui/math-popover"

import type { ButtonProps } from "@/components/tiptap-ui-primitive/button"
import { Button } from "@/components/tiptap-ui-primitive/button"
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/tiptap-ui-primitive/popover"
import {
  Card,
  CardBody,
  CardItemGroup,
} from "@/components/tiptap-ui-primitive/card"
import { Input } from "@/components/tiptap-ui-primitive/input"
import { ButtonGroup } from "@/components/tiptap-ui-primitive/button-group"

import "./math-popover.scss"

export interface MathMainProps {
  latex: string
  setLatex: React.Dispatch<React.SetStateAction<string | null>>
  insertMath: () => void
}

export interface MathPopoverProps
  extends Omit<ButtonProps, "type">, UseMathPopoverConfig {
  onOpenChange?: (isOpen: boolean) => void
}

export const MathButton = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, children, ...props }, ref) => {
    return (
      <Button
        type="button"
        className={className}
        variant="ghost"
        role="button"
        tabIndex={-1}
        aria-label="رياضيات"
        tooltip="رياضيات"
        ref={ref}
        {...props}
      >
        {children || <SigmaIcon className="tiptap-button-icon" />}
      </Button>
    )
  }
)

MathButton.displayName = "MathButton"

const MathMain: React.FC<{
  latex: string
  setLatex: React.Dispatch<React.SetStateAction<string | null>>
  insertMath: () => void
}> = ({ latex, setLatex, insertMath }) => {
  const isMobile = useIsBreakpoint()

  const handleKeyDown = (event: React.KeyboardEvent<HTMLInputElement>) => {
    if (event.key === "Enter") {
      event.preventDefault()
      insertMath()
    }
  }

  return (
    <Card
      style={{
        ...(isMobile ? { boxShadow: "none", border: 0 } : {}),
      }}
    >
      <CardBody
        style={{
          ...(isMobile ? { padding: 0 } : {}),
        }}
      >
        <CardItemGroup orientation="horizontal">
          <Input
            type="text"
            placeholder="أدخل معادلة LaTeX..."
            value={latex}
            onChange={(e) => setLatex(e.target.value)}
            onKeyDown={handleKeyDown}
            autoFocus
            autoComplete="off"
            autoCorrect="off"
            autoCapitalize="off"
            spellCheck={false}
            className="tiptap-math-input"
          />

          <ButtonGroup>
            <Button
              type="button"
              onClick={insertMath}
              title="إدراج المعادلة"
              disabled={!latex}
              variant="ghost"
            >
              <CornerDownLeftIcon className="tiptap-button-icon" />
            </Button>
          </ButtonGroup>
        </CardItemGroup>
      </CardBody>
    </Card>
  )
}

export const MathContent: React.FC<{
  editor?: Editor | null
}> = ({ editor }) => {
  const { latex, setLatex, insertMath } = useMathPopover({ editor })
  return <MathMain latex={latex} setLatex={setLatex} insertMath={insertMath} />
}

export const MathPopover = forwardRef<HTMLButtonElement, MathPopoverProps>(
  (
    {
      editor: providedEditor,
      hideWhenUnavailable = false,
      onSetMath,
      onOpenChange,
      onClick,
      children,
      ...buttonProps
    },
    ref
  ) => {
    const { editor } = useTiptapEditor(providedEditor)
    const [isOpen, setIsOpen] = useState(false)

    const {
      isVisible,
      canSet,
      isActive,
      latex,
      setLatex,
      insertMath,
      removeMath,
      label,
      Icon,
    } = useMathPopover({
      editor,
      hideWhenUnavailable,
      onSetMath,
    })

    const handleOnOpenChange = useCallback(
      (nextIsOpen: boolean) => {
        setIsOpen(nextIsOpen)
        onOpenChange?.(nextIsOpen)
      },
      [onOpenChange]
    )

    const handleInsertMath = useCallback(() => {
      insertMath()
      setIsOpen(false)
    }, [insertMath])

    const handleClick = useCallback(
      (event: React.MouseEvent<HTMLButtonElement>) => {
        onClick?.(event)
        if (event.defaultPrevented) return
        const selectedLatex = getSelectedMathLatex(editor)
        if (selectedLatex) {
          setLatex(selectedLatex)
        }
        setIsOpen(!isOpen)
      },
      [onClick, isOpen, editor, setLatex]
    )

    if (!isVisible) {
      return null
    }

    return (
      <Popover open={isOpen} onOpenChange={handleOnOpenChange}>
        <PopoverTrigger asChild>
          <MathButton
            disabled={!canSet}
            data-active-state={isActive ? "on" : "off"}
            data-disabled={!canSet}
            aria-label={label}
            aria-pressed={isActive}
            onClick={handleClick}
            {...buttonProps}
            ref={ref}
          >
            {children ?? <Icon className="tiptap-button-icon" />}
          </MathButton>
        </PopoverTrigger>

        <PopoverContent collisionPadding={4}>
          <MathMain
            latex={latex}
            setLatex={setLatex}
            insertMath={handleInsertMath}
          />
        </PopoverContent>
      </Popover>
    )
  }
)

MathPopover.displayName = "MathPopover"

export default MathPopover
