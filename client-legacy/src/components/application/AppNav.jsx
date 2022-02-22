export default function AppNav({ children }) {
    return (
      <nav className="p-4">
        <ul className="flex space-x-2">
          {children}
        </ul>
      </nav>
    )
  }
  