import type { Schema, Struct } from '@strapi/strapi';

export interface PagepartsJobListComponent extends Struct.ComponentSchema {
  collectionName: 'components_pageparts_job_list_components';
  info: {
    displayName: 'Job List - Component';
    icon: 'bulletList';
  };
  attributes: {
    jobs: Schema.Attribute.Relation<'oneToMany', 'api::job.job'>;
  };
}

export interface PagepartsProjectListComponent extends Struct.ComponentSchema {
  collectionName: 'components_pageparts_project_list_components';
  info: {
    displayName: 'Project List - Component';
    icon: 'bulletList';
  };
  attributes: {
    projects: Schema.Attribute.Relation<'oneToMany', 'api::project.project'>;
  };
}

export interface PagepartsTechStackComponent extends Struct.ComponentSchema {
  collectionName: 'components_pageparts_tech_stack_components';
  info: {
    displayName: 'TechStack List - Component';
  };
  attributes: {
    tech_stacks: Schema.Attribute.Relation<
      'oneToMany',
      'api::tech-stack.tech-stack'
    >;
  };
}

declare module '@strapi/strapi' {
  export module Public {
    export interface ComponentSchemas {
      'pageparts.job-list-component': PagepartsJobListComponent;
      'pageparts.project-list-component': PagepartsProjectListComponent;
      'pageparts.tech-stack-component': PagepartsTechStackComponent;
    }
  }
}
