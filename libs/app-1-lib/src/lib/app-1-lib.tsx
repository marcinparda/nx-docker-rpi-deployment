import styles from './app-1-lib.module.css';

export interface App1LibProps {
  message?: string;
}

export function App1Lib(props: App1LibProps) {
  return (
    <div className={styles['container']}>
      <h1>App-1 Specific Component</h1>
      <h2>Final Flash!</h2>
      <p>{props.message || 'This component is specific to App-1!'}</p>
    </div>
  );
}

export default App1Lib;
