import { Pipe, PipeTransform } from '@angular/core';

@Pipe({ name: 'enrolledCount', standalone: true })
export class EnrolledCountPipe implements PipeTransform {
  transform(students: any[], subjectId: number): number {
    if (!students) return 0;
    return students.filter(s =>
      (s.subjects || []).some((sub: any) => sub.id === subjectId)
    ).length;
  }
}