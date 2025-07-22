import { render } from '@testing-library/react';

import NxDockerRpiDeploymentApp1Lib from './app-1-lib';

describe('NxDockerRpiDeploymentApp1Lib', () => {
  it('should render successfully', () => {
    const { baseElement } = render(<NxDockerRpiDeploymentApp1Lib />);
    expect(baseElement).toBeTruthy();
  });
});
