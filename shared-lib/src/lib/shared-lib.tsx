import styles from './shared-lib.module.css';

export interface SharedLibProps {
  title?: string;
}

export function SharedLib(props: SharedLibProps) {
  return (
    <div className={styles['container']}>
      <h1>Welcome to {props.title || 'Shared Component'}!</h1>
      <p>This component is shared between multiple applications.</p>
    </div>
  );
}

export default SharedLib;
