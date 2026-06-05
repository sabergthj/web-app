import { Outlet, NavLink } from 'react-router-dom';
import styles from './Layout.module.css';

const NAV_ITEMS = [
  { to: '/dashboard', label: '📊 仪表盘', icon: '📊' },
  { to: '/products', label: '📦 商品管理', icon: '📦' },
  { to: '/orders', label: '📋 订单管理', icon: '📋' },
  { to: '/inventory', label: '🏗️ 库存管理', icon: '🏗️' },
  { to: '/customers', label: '👥 客户管理', icon: '👥' },
  { to: '/analytics', label: '📈 销售报表', icon: '📈' },
];

export default function Layout() {
  return (
    <div className={styles.container}>
      <aside className={styles.sidebar}>
        <div className={styles.brand}>零电商管理</div>
        <nav className={styles.nav}>
          {NAV_ITEMS.map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              className={({ isActive }) =>
                `${styles.navItem} ${isActive ? styles.active : ''}`
              }
            >
              <span className={styles.icon}>{item.icon}</span>
              {item.label}
            </NavLink>
          ))}
        </nav>
      </aside>
      <main className={styles.main}>
        <header className={styles.header}>
          <h2 className={styles.title}>全自动化电商管理系统</h2>
        </header>
        <div className={styles.content}>
          <Outlet />
        </div>
      </main>
    </div>
  );
}
