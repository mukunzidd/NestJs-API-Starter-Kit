import { ValidationPipe as NestValidationPipe, BadRequestException } from '@nestjs/common';
import { ValidationError } from 'class-validator';

export class ValidationPipe extends NestValidationPipe {
  constructor() {
    super({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
      exceptionFactory: (validationErrors: ValidationError[] = []) => {
        const errors = this.customFlattenValidationErrors(validationErrors);
        return new BadRequestException({
          message: 'Validation failed',
          errors,
        });
      },
    });
  }

  private customFlattenValidationErrors(validationErrors: ValidationError[]): any[] {
    const errors: any[] = [];

    const extractErrors = (error: ValidationError, parentPath: string = '') => {
      const currentPath = parentPath ? `${parentPath}.${error.property}` : error.property;

      if (error.constraints) {
        Object.values(error.constraints).forEach((constraint) => {
          errors.push({
            field: currentPath,
            message: constraint,
            value: error.value,
          });
        });
      }

      if (error.children && error.children.length > 0) {
        error.children.forEach((child) => {
          extractErrors(child, currentPath);
        });
      }
    };

    validationErrors.forEach((error) => {
      extractErrors(error);
    });

    return errors;
  }
}
