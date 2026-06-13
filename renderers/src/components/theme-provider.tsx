import { createContext, useContext, useEffect, useState } from "react"

export type Theme = "dark" | "light" | "system"

type ThemeProviderProps = {
  children: React.ReactNode
  defaultTheme?: Theme
  storageKey?: string
}

type ThemeProviderState = {
  theme: Theme
  setTheme: (theme: Theme) => void
}

const initialState: ThemeProviderState = {
  theme: "system",
  setTheme: () => null,
}

const ThemeProviderContext = createContext<ThemeProviderState>(initialState)

function readStoredTheme(storageKey: string): Theme | null {
  if (window.location.protocol === "data:") {
    return null
  }

  try {
    const value = localStorage.getItem(storageKey)
    if (value === "dark" || value === "light" || value === "system") {
      return value
    }
  } catch {
    // localStorage is unavailable in data: URLs and some embedded WebViews.
  }

  return null
}

function writeStoredTheme(storageKey: string, theme: Theme) {
  if (window.location.protocol === "data:") {
    return
  }

  try {
    localStorage.setItem(storageKey, theme)
  } catch {
    // Ignore when storage is unavailable; Flutter controls theme at runtime.
  }
}

export function ThemeProvider({
  children,
  defaultTheme = "system",
  storageKey = "vite-ui-theme",
  ...props
}: ThemeProviderProps) {
  const [theme, setTheme] = useState<Theme>(
    () => readStoredTheme(storageKey) ?? defaultTheme,
  )

  useEffect(() => {
    const root = window.document.documentElement

    root.classList.remove("light", "dark")

    if (theme === "system") {
      const systemTheme = window.matchMedia("(prefers-color-scheme: dark)")
        .matches ?
        "dark" :
        "light"

      root.classList.add(systemTheme)
      return
    }

    root.classList.add(theme)
  }, [theme])

  const value = {
    theme,
    setTheme: (theme: Theme) => {
      writeStoredTheme(storageKey, theme)
      setTheme(theme)
    },
  }

  return (
    <ThemeProviderContext.Provider {...props} value={value}>
      {children}
    </ThemeProviderContext.Provider>
  )
}

export const useTheme = () => {
  const context = useContext(ThemeProviderContext)

  if (context === undefined) { throw new Error("useTheme must be used within a ThemeProvider") }

  return context
}
