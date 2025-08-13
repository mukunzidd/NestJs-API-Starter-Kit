import { PipeTransform, Injectable, ArgumentMetadata, BadRequestException } from '@nestjs/common';

/**
 * Custom ParseDatePipe implementation compatible with NestJS 11
 * This can be replaced with @nestjs/common ParseDatePipe when upgrading
 */
@Injectable()
export class ParseDatePipe implements PipeTransform<string, Date> {
  constructor(private readonly options?: { optional?: boolean }) {}

  transform(value: string, metadata: ArgumentMetadata): Date {
    if (!value) {
      if (this.options?.optional) {
        return undefined as any;
      }
      throw new BadRequestException(
        `Validation failed for ${metadata.data || 'parameter'}. Expected a valid date string.`,
      );
    }

    const date = new Date(value);

    if (isNaN(date.getTime())) {
      throw new BadRequestException(
        `Validation failed for ${metadata.data || 'parameter'}. "${value}" is not a valid date.`,
      );
    }

    return date;
  }
}

/**
 * Optional ParseDatePipe that allows undefined values
 */
@Injectable()
export class ParseOptionalDatePipe extends ParseDatePipe {
  constructor() {
    super({ optional: true });
  }
}
