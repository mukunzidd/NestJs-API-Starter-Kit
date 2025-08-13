import { Logger } from '@nestjs/common';
import { AppDataSource } from '../data-source';

const logger = new Logger('DatabaseSeeds');

async function runSeeds() {
  try {
    logger.log('🌱 Starting database seeding...');

    if (!AppDataSource.isInitialized) {
      await AppDataSource.initialize();
      logger.log('📊 Database connection established');
    }

    // Add your seed logic here
    // Example:
    // const userRepository = AppDataSource.getRepository(User);
    // await userRepository.save({...});

    logger.log('✅ Database seeding completed successfully!');
  } catch (error) {
    logger.error('❌ Database seeding failed:', error);
    process.exit(1);
  } finally {
    if (AppDataSource.isInitialized) {
      await AppDataSource.destroy();
      logger.log('🔌 Database connection closed');
    }
  }
}

// Only run if this file is executed directly
if (require.main === module) {
  runSeeds().catch((error) => {
    logger.error('❌ Unexpected error during seeding:', error);
    process.exit(1);
  });
}
