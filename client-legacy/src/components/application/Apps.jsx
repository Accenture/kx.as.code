import AppNav from './AppNav.jsx'
import NavItem from './NavItem.jsx'
import AppList from './AppList.jsx'
import ListAppItem from './ListAppItem.jsx'

export default function Apps({ apps }) {
  return (
    <div className="divide-y divide-gray-100">
      <AppNav>
        <NavItem href="/pending" isActive>Pending</NavItem>
        <NavItem href="/completed">Completed</NavItem>
        <NavItem href="/failed">Failed</NavItem>
        <NavItem href="/wip">WIP</NavItem>
        <NavItem href="/retry">Retry</NavItem>
      </AppNav>
      <AppList>
        {apps.map((app) => (
          <ListAppItem key={app.id} app={app} />
        ))}
      </AppList>
    </div>
  )
}