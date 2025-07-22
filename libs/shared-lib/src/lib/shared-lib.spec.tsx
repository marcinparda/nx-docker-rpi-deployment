import { render } from '@testing-library/react';

import NxDockerRpiDeploymentSharedLib from './shared-lib';

describe('NxDockerRpiDeploymentSharedLib', () => {
  it('should render successfully', () => {
    const { baseElement } = render(<NxDockerRpiDeploymentSharedLib />);
    expect(baseElement).toBeTruthy();
  });
});
