import 'reflect-metadata';

// Mock console methods in test environment
const originalConsole = { ...console };

beforeAll(() => {
  // Suppress console output during tests unless explicitly needed
  jest.spyOn(console, 'log').mockImplementation(() => {});
  jest.spyOn(console, 'warn').mockImplementation(() => {});
  jest.spyOn(console, 'error').mockImplementation(() => {});
  jest.spyOn(console, 'info').mockImplementation(() => {});
});

afterAll(() => {
  // Restore console methods
  // eslint-disable-next-line no-console
  console.log = originalConsole.log;
  // eslint-disable-next-line no-console
  console.warn = originalConsole.warn;
  // eslint-disable-next-line no-console
  console.error = originalConsole.error;
  // eslint-disable-next-line no-console
  console.info = originalConsole.info;
});

// Global test utilities
global.testUtils = {
  createMockRequest: (overrides = {}) => ({
    url: '/test',
    method: 'GET',
    ip: '127.0.0.1',
    headers: {
      'user-agent': 'test-agent',
    },
    body: {},
    query: {},
    params: {},
    connection: {
      remoteAddress: '127.0.0.1',
    },
    ...overrides,
  }),

  createMockResponse: (overrides = {}) => ({
    statusCode: 200,
    status: jest.fn().mockReturnThis(),
    json: jest.fn().mockReturnThis(),
    send: jest.fn().mockReturnThis(),
    ...overrides,
  }),

  createMockConfigService: (config = {}) => ({
    get: jest.fn((key: string) => {
      const defaultConfig = {
        NODE_ENV: 'test',
        PORT: 3000,
        HOST: '0.0.0.0',
        'app.name': 'Test App',
        'app.version': '1.0.0',
        'app.description': 'Test Description',
      };
      return config[key] || defaultConfig[key];
    }),
  }),
};
