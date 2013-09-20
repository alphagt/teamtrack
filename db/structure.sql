CREATE TABLE "assignments" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "is_fixed" boolean, "effort" float, "user_id" integer, "project_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "set_period_id" integer);
CREATE TABLE "projects" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "active" boolean, "owner_id" integer, "description" varchar(255), "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "fixed_resource_budget" integer, "category" varchar(255) DEFAULT 'Unassigned');
CREATE TABLE "schema_migrations" ("version" varchar(255) NOT NULL);
CREATE TABLE "set_periods" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "fiscal_year" integer, "week_number" integer, "cweek_offset" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE "users" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "email" varchar(255) DEFAULT '' NOT NULL, "encrypted_password" varchar(255) DEFAULT '' NOT NULL, "reset_password_token" varchar(255), "reset_password_sent_at" datetime, "remember_created_at" datetime, "sign_in_count" integer DEFAULT 0, "current_sign_in_at" datetime, "last_sign_in_at" datetime, "current_sign_in_ip" varchar(255), "last_sign_in_ip" varchar(255), "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "name" varchar(255), "admin" boolean DEFAULT 'f' NOT NULL, "ismanager" boolean DEFAULT 'f' NOT NULL, "manager_id" integer, "verified" boolean DEFAULT 'f', "isstatususer" boolean, "impersonate_manager" integer DEFAULT 0);
CREATE INDEX "index_assignments_on_project_id" ON "assignments" ("project_id");
CREATE INDEX "index_assignments_on_set_period_id" ON "assignments" ("set_period_id");
CREATE INDEX "index_assignments_on_user_id" ON "assignments" ("user_id");
CREATE INDEX "index_projects_on_category" ON "projects" ("category");
CREATE UNIQUE INDEX "index_users_on_email" ON "users" ("email");
CREATE INDEX "index_users_on_manager_id" ON "users" ("manager_id");
CREATE UNIQUE INDEX "index_users_on_reset_password_token" ON "users" ("reset_password_token");
CREATE UNIQUE INDEX "unique_schema_migrations" ON "schema_migrations" ("version");
INSERT INTO schema_migrations (version) VALUES ('20121112061120');

INSERT INTO schema_migrations (version) VALUES ('20121112061915');

INSERT INTO schema_migrations (version) VALUES ('20121112064528');

INSERT INTO schema_migrations (version) VALUES ('20121114032435');

INSERT INTO schema_migrations (version) VALUES ('20121114035740');

INSERT INTO schema_migrations (version) VALUES ('20121114040736');

INSERT INTO schema_migrations (version) VALUES ('20121114054332');

INSERT INTO schema_migrations (version) VALUES ('20121118203943');

INSERT INTO schema_migrations (version) VALUES ('20121125043702');

INSERT INTO schema_migrations (version) VALUES ('20121126202651');

INSERT INTO schema_migrations (version) VALUES ('20121217154704');

INSERT INTO schema_migrations (version) VALUES ('20130114042941');

INSERT INTO schema_migrations (version) VALUES ('20130411170158');

INSERT INTO schema_migrations (version) VALUES ('20130603114941');

INSERT INTO schema_migrations (version) VALUES ('20130604073208');

INSERT INTO schema_migrations (version) VALUES ('20130920194046');