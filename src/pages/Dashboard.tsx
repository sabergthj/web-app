import styles from './Dashboard.module.css';

export default function Dashboard() {
  return (
    <div className={styles.page}>
      <h1>仪表盘</h1>
      <div className={styles.grid}>
        <div className={styles.card}>
          <div className={styles.cardValue}>¥128,430</div>
          <div className={styles.cardLabel}>今日销售额</div>
        </div>
        <div className={styles.card}>
          <div className={styles.cardValue}>342</div>
          <div className={styles.cardLabel}>待处理订单</div>
        </div>
        <div className={styles.card}>
          <div className={styles.cardValue}>1,280</div>
          <div className={styles.cardLabel}>商品总数</div>
        </div>
        <div className={styles.card}>
          <div className={styles.cardValue}>8,562</div>
          <div className={styles.cardLabel}>活跃客户</div>
        </div>
      </div>
    </div>
  );
}
