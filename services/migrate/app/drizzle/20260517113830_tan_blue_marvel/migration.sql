CREATE TYPE "tmdb"."company_kind" AS ENUM('production_company', 'tv_network');

--> statement-breakpoint
CREATE TYPE "tmdb"."facet_kind" AS ENUM('genres', 'keywords');

--> statement-breakpoint
CREATE TYPE "tmdb"."person_image_kind" AS ENUM('profiles');

--> statement-breakpoint
CREATE TYPE "tmdb"."person_field" AS ENUM('name', 'biography');

--> statement-breakpoint
CREATE TYPE "tmdb"."title_kind" AS ENUM('movie', 'show', 'season', 'episode');

--> statement-breakpoint
CREATE TYPE "tmdb"."title_country_kind" AS ENUM('origin', 'production');

--> statement-breakpoint
CREATE TYPE "tmdb"."title_credit_kind" AS ENUM('cast', 'crew');

--> statement-breakpoint
CREATE TYPE "tmdb"."title_image_kind" AS ENUM('backdrops', 'logos', 'posters');

--> statement-breakpoint
CREATE TYPE "tmdb"."title_relation_kind" AS ENUM('similar', 'recommendations');

--> statement-breakpoint
CREATE TYPE "tmdb"."title_field" AS ENUM(
  'name',
  'overview',
  'tagline',
  'homepage',
  'runtime'
);

--> statement-breakpoint
CREATE TABLE "tmdb"."collection" (
  "id" INTEGER PRIMARY KEY,
  "name" TEXT NOT NULL,
  "original_name" TEXT NOT NULL,
  "original_language" TEXT NOT NULL,
  "overview" TEXT,
  "poster_path" TEXT,
  "backdrop_path" TEXT,
  "created_ts" TIMESTAMP DEFAULT now() NOT NULL,
  "updated_ts" TIMESTAMP DEFAULT now() NOT NULL,
  "version_ts" TIMESTAMP NOT NULL
);

--> statement-breakpoint
CREATE TABLE "tmdb"."collection_part" (
  "collection_id" INTEGER,
  "part_id" INTEGER,
  "media_type" TEXT NOT NULL,
  "part_index" INTEGER,
  "version_ts" TIMESTAMP NOT NULL,
  CONSTRAINT "collection_part_pkey" PRIMARY KEY ("collection_id", "part_id")
);

--> statement-breakpoint
CREATE TABLE "tmdb"."company" (
  "id" INTEGER,
  "kind" "tmdb"."company_kind",
  "name" TEXT NOT NULL,
  "description" TEXT,
  "homepage" TEXT,
  "headquarters" TEXT,
  "origin_country" TEXT,
  "logo_path" TEXT,
  "parent_company" INTEGER,
  "created_ts" TIMESTAMP DEFAULT now() NOT NULL,
  "updated_ts" TIMESTAMP DEFAULT now() NOT NULL,
  CONSTRAINT "company_pkey" PRIMARY KEY ("id", "kind")
);

--> statement-breakpoint
CREATE TABLE "tmdb"."country" (
  "iso_3166_1" TEXT PRIMARY KEY,
  "name" TEXT NOT NULL
);

--> statement-breakpoint
CREATE TABLE "tmdb"."facet" (
  "id" INTEGER,
  "kind" "tmdb"."facet_kind",
  "name" TEXT NOT NULL,
  "created_ts" TIMESTAMP DEFAULT now() NOT NULL,
  "updated_ts" TIMESTAMP DEFAULT now() NOT NULL,
  CONSTRAINT "facet_pkey" PRIMARY KEY ("id", "kind")
);

--> statement-breakpoint
CREATE TABLE "tmdb"."language" (
  "iso_639_1" TEXT PRIMARY KEY,
  "name" TEXT,
  "english_name" TEXT NOT NULL
);

--> statement-breakpoint
CREATE TABLE "tmdb"."list" (
  "id" INTEGER PRIMARY KEY,
  "name" TEXT NOT NULL,
  "description" TEXT,
  "iso_3166_1" TEXT NOT NULL,
  "iso_639_1" TEXT NOT NULL,
  "item_count" INTEGER NOT NULL,
  "favorite_count" INTEGER NOT NULL,
  "poster_path" TEXT,
  "list_type" TEXT NOT NULL
);

--> statement-breakpoint
CREATE TABLE "tmdb"."person" (
  "id" INTEGER PRIMARY KEY,
  "name" TEXT NOT NULL,
  "biography" TEXT,
  "birthday" date,
  "deathday" date,
  "gender" INTEGER NOT NULL,
  "homepage" TEXT,
  "imdb_id" TEXT,
  "known_for_department" TEXT,
  "place_of_birth" TEXT,
  "popularity" NUMERIC NOT NULL,
  "profile_path" TEXT,
  "adult" BOOLEAN NOT NULL,
  "created_ts" TIMESTAMP DEFAULT now() NOT NULL,
  "updated_ts" TIMESTAMP DEFAULT now() NOT NULL,
  "version_ts" TIMESTAMP NOT NULL
);

--> statement-breakpoint
CREATE TABLE "tmdb"."person_aka" (
  "also_known_as" TEXT,
  "person_id" INTEGER,
  "version_ts" TIMESTAMP NOT NULL,
  CONSTRAINT "person_aka_pkey" PRIMARY KEY ("person_id", "also_known_as")
);

--> statement-breakpoint
CREATE TABLE "tmdb"."person_image" (
  "kind" "tmdb"."person_image_kind",
  "file_path" TEXT,
  "aspect_ratio" NUMERIC NOT NULL,
  "width" SMALLINT NOT NULL,
  "height" SMALLINT NOT NULL,
  "vote_average" NUMERIC NOT NULL,
  "vote_count" INTEGER NOT NULL,
  "person_id" INTEGER,
  "version_ts" TIMESTAMP NOT NULL,
  CONSTRAINT "person_image_pkey" PRIMARY KEY ("person_id", "kind", "file_path")
);

--> statement-breakpoint
CREATE TABLE "tmdb"."person_translation" (
  "iso_3166_1" TEXT,
  "iso_639_1" TEXT,
  "field" "tmdb"."person_field",
  "value" TEXT NOT NULL,
  "primary" BOOLEAN NOT NULL,
  "person_id" INTEGER,
  "version_ts" TIMESTAMP NOT NULL,
  CONSTRAINT "person_translation_pkey" PRIMARY KEY ("person_id", "iso_3166_1", "iso_639_1", "field")
);

--> statement-breakpoint
CREATE TABLE "tmdb"."title" (
  "id" INTEGER,
  "kind" "tmdb"."title_kind",
  "name" TEXT NOT NULL,
  "original_name" TEXT NOT NULL,
  "original_language" TEXT NOT NULL,
  "backdrop_path" TEXT,
  "homepage" TEXT,
  "overview" TEXT,
  "tagline" TEXT,
  "popularity" NUMERIC NOT NULL,
  "poster_path" TEXT,
  "release_date" date,
  "softcore" BOOLEAN NOT NULL,
  "status" TEXT NOT NULL,
  "vote_average" NUMERIC NOT NULL,
  "vote_count" INTEGER NOT NULL,
  "adult" BOOLEAN NOT NULL,
  "created_ts" TIMESTAMP DEFAULT now() NOT NULL,
  "updated_ts" TIMESTAMP DEFAULT now() NOT NULL,
  "version_ts" TIMESTAMP NOT NULL,
  CONSTRAINT "title_pkey" PRIMARY KEY ("id", "kind")
);

--> statement-breakpoint
CREATE TABLE "tmdb"."title_alternative_title" (
  "iso_3166_1" TEXT,
  "title" TEXT,
  "type" TEXT,
  "title_id" INTEGER,
  "title_kind" "tmdb"."title_kind",
  "version_ts" TIMESTAMP NOT NULL,
  CONSTRAINT "title_alternative_title_pkey" PRIMARY KEY ("title_id", "title_kind", "iso_3166_1", "title")
);

--> statement-breakpoint
CREATE TABLE "tmdb"."title_company" (
  "company_id" INTEGER,
  "company_kind" "tmdb"."company_kind",
  "title_id" INTEGER,
  "title_kind" "tmdb"."title_kind",
  "version_ts" TIMESTAMP NOT NULL,
  CONSTRAINT "title_company_pkey" PRIMARY KEY (
    "title_id",
    "title_kind",
    "company_id",
    "company_kind"
  )
);

--> statement-breakpoint
CREATE TABLE "tmdb"."title_country" (
  "kind" "tmdb"."title_country_kind",
  "iso_3166_1" TEXT,
  "title_id" INTEGER,
  "title_kind" "tmdb"."title_kind",
  "version_ts" TIMESTAMP NOT NULL,
  CONSTRAINT "title_country_pkey" PRIMARY KEY ("title_id", "title_kind", "kind", "iso_3166_1")
);

--> statement-breakpoint
CREATE TABLE "tmdb"."title_credit" (
  "credit_id" UUID PRIMARY KEY,
  "person_id" INTEGER NOT NULL,
  "kind" "tmdb"."title_credit_kind" NOT NULL,
  "guest" BOOLEAN DEFAULT FALSE NOT NULL,
  "title_id" INTEGER NOT NULL,
  "title_kind" "tmdb"."title_kind" NOT NULL,
  "version_ts" TIMESTAMP NOT NULL
);

--> statement-breakpoint
CREATE TABLE "tmdb"."title_credit_cast" (
  "credit_id" UUID PRIMARY KEY,
  "cast_id" INTEGER,
  "order" INTEGER NOT NULL,
  "character" TEXT,
  "version_ts" TIMESTAMP NOT NULL
);

--> statement-breakpoint
CREATE TABLE "tmdb"."title_credit_crew" (
  "credit_id" UUID PRIMARY KEY,
  "department" TEXT NOT NULL,
  "job" TEXT NOT NULL,
  "version_ts" TIMESTAMP NOT NULL
);

--> statement-breakpoint
CREATE TABLE "tmdb"."title_embed" (
  "model_id" TEXT,
  "model_dimensions" SMALLINT NOT NULL,
  "input" TEXT NOT NULL,
  "embedding" halfvec (2048) NOT NULL,
  "title_id" INTEGER,
  "title_kind" "tmdb"."title_kind",
  "version_ts" TIMESTAMP NOT NULL,
  CONSTRAINT "title_embed_pkey" PRIMARY KEY ("title_id", "title_kind", "model_id")
);

--> statement-breakpoint
CREATE TABLE "tmdb"."title_facet" (
  "facet_id" INTEGER,
  "facet_kind" "tmdb"."facet_kind",
  "title_id" INTEGER,
  "title_kind" "tmdb"."title_kind",
  "version_ts" TIMESTAMP NOT NULL,
  CONSTRAINT "title_facet_pkey" PRIMARY KEY (
    "title_id",
    "title_kind",
    "facet_id",
    "facet_kind"
  )
);

--> statement-breakpoint
CREATE TABLE "tmdb"."title_image" (
  "kind" "tmdb"."title_image_kind",
  "file_path" TEXT,
  "iso_639_1" TEXT,
  "iso_3166_1" TEXT,
  "width" INTEGER NOT NULL,
  "height" INTEGER NOT NULL,
  "aspect_ratio" NUMERIC NOT NULL,
  "vote_average" NUMERIC NOT NULL,
  "vote_count" INTEGER NOT NULL,
  "title_id" INTEGER,
  "title_kind" "tmdb"."title_kind",
  "version_ts" TIMESTAMP NOT NULL,
  CONSTRAINT "title_image_pkey" PRIMARY KEY ("title_id", "title_kind", "kind", "file_path")
);

--> statement-breakpoint
CREATE TABLE "tmdb"."title_language" (
  "iso_639_1" TEXT,
  "title_id" INTEGER,
  "title_kind" "tmdb"."title_kind",
  "version_ts" TIMESTAMP NOT NULL,
  CONSTRAINT "title_language_pkey" PRIMARY KEY ("title_id", "title_kind", "iso_639_1")
);

--> statement-breakpoint
CREATE TABLE "tmdb"."title_list" (
  "list_id" INTEGER,
  "title_id" INTEGER,
  "title_kind" "tmdb"."title_kind",
  "version_ts" TIMESTAMP NOT NULL,
  CONSTRAINT "title_list_pkey" PRIMARY KEY ("title_id", "title_kind", "list_id")
);

--> statement-breakpoint
CREATE TABLE "tmdb"."title_relation" (
  "kind" "tmdb"."title_relation_kind",
  "related_id" INTEGER,
  "related_kind" "tmdb"."title_kind",
  "title_id" INTEGER,
  "title_kind" "tmdb"."title_kind",
  "version_ts" TIMESTAMP NOT NULL,
  CONSTRAINT "title_relation_pkey" PRIMARY KEY (
    "title_id",
    "title_kind",
    "kind",
    "related_id",
    "related_kind"
  )
);

--> statement-breakpoint
CREATE TABLE "tmdb"."title_review" (
  "id" UUID PRIMARY KEY,
  "author" TEXT NOT NULL,
  "content" TEXT NOT NULL,
  "url" TEXT NOT NULL,
  "created_at" TIMESTAMP NOT NULL,
  "updated_at" TIMESTAMP NOT NULL,
  "author_avatar_path" TEXT,
  "author_name" TEXT,
  "author_rating" NUMERIC,
  "author_username" TEXT NOT NULL,
  "title_id" INTEGER NOT NULL,
  "title_kind" "tmdb"."title_kind" NOT NULL,
  "version_ts" TIMESTAMP NOT NULL
);

--> statement-breakpoint
CREATE TABLE "tmdb"."title_translation" (
  "iso_3166_1" TEXT,
  "iso_639_1" TEXT,
  "field" "tmdb"."title_field",
  "value" TEXT NOT NULL,
  "title_id" INTEGER,
  "title_kind" "tmdb"."title_kind",
  "version_ts" TIMESTAMP NOT NULL,
  CONSTRAINT "title_translation_pkey" PRIMARY KEY (
    "title_id",
    "title_kind",
    "iso_3166_1",
    "iso_639_1",
    "field"
  )
);

--> statement-breakpoint
CREATE TABLE "tmdb"."title_video" (
  "id" UUID PRIMARY KEY,
  "key" TEXT NOT NULL,
  "name" TEXT,
  "iso_3166_1" TEXT NOT NULL,
  "iso_639_1" TEXT NOT NULL,
  "official" BOOLEAN NOT NULL,
  "published_at" date NOT NULL,
  "site" TEXT NOT NULL,
  "size" SMALLINT NOT NULL,
  "type" TEXT NOT NULL,
  "title_id" INTEGER NOT NULL,
  "title_kind" "tmdb"."title_kind" NOT NULL,
  "version_ts" TIMESTAMP NOT NULL
);

--> statement-breakpoint
CREATE TABLE "tmdb"."title_movie" (
  "budget" BIGINT NOT NULL,
  "revenue" BIGINT NOT NULL,
  "runtime" INTEGER NOT NULL,
  "imdb_id" TEXT,
  "collection_id" INTEGER,
  "video" BOOLEAN NOT NULL,
  "title_id" INTEGER PRIMARY KEY,
  "version_ts" TIMESTAMP NOT NULL
);

--> statement-breakpoint
CREATE TABLE "tmdb"."title_release_date" (
  "certification" TEXT,
  "descriptors" TEXT[] NOT NULL,
  "iso_3166_1" TEXT,
  "iso_639_1" TEXT,
  "note" TEXT,
  "release_date" date,
  "type" INTEGER,
  "title_id" INTEGER,
  "version_ts" TIMESTAMP NOT NULL,
  CONSTRAINT "title_release_date_pkey" PRIMARY KEY ("title_id", "iso_3166_1", "type", "release_date")
);

--> statement-breakpoint
CREATE TABLE "tmdb"."title_show" (
  "number_of_episodes" INTEGER,
  "number_of_seasons" INTEGER NOT NULL,
  "last_air_date" date,
  "in_production" BOOLEAN NOT NULL,
  "last_episode_id" INTEGER,
  "next_episode_id" INTEGER,
  "type" TEXT NOT NULL,
  "title_id" INTEGER PRIMARY KEY,
  "version_ts" TIMESTAMP NOT NULL
);

--> statement-breakpoint
CREATE TABLE "tmdb"."title_content_rating" (
  "iso_3166_1" TEXT,
  "rating" TEXT NOT NULL,
  "descriptors" TEXT[] NOT NULL,
  "title_id" INTEGER,
  "version_ts" TIMESTAMP NOT NULL,
  CONSTRAINT "title_content_rating_pkey" PRIMARY KEY ("title_id", "iso_3166_1")
);

--> statement-breakpoint
CREATE TABLE "tmdb"."title_created_by" (
  "person_id" INTEGER,
  "title_id" INTEGER,
  "version_ts" TIMESTAMP NOT NULL,
  CONSTRAINT "title_created_by_pkey" PRIMARY KEY ("title_id", "person_id")
);

--> statement-breakpoint
CREATE TABLE "tmdb"."title_episode_group" (
  "id" UUID PRIMARY KEY,
  "name" TEXT NOT NULL,
  "description" TEXT,
  "group_count" INTEGER NOT NULL,
  "episode_count" INTEGER NOT NULL,
  "type" INTEGER NOT NULL,
  "company_id" INTEGER,
  "title_id" INTEGER NOT NULL,
  "version_ts" TIMESTAMP NOT NULL
);

--> statement-breakpoint
CREATE TABLE "tmdb"."title_episode" (
  "id" INTEGER PRIMARY KEY,
  "show_id" INTEGER,
  "season_number" SMALLINT NOT NULL,
  "episode_number" SMALLINT NOT NULL,
  "name" TEXT NOT NULL,
  "episode_type" TEXT NOT NULL,
  "air_date" TIMESTAMP,
  "overview" TEXT,
  "production_code" TEXT,
  "still_path" TEXT,
  "runtime" SMALLINT,
  "vote_average" NUMERIC NOT NULL,
  "vote_count" INTEGER NOT NULL,
  "title_id" INTEGER NOT NULL,
  "version_ts" TIMESTAMP NOT NULL
);

--> statement-breakpoint
CREATE TABLE "tmdb"."title_screened_theatrically" (
  "id" INTEGER PRIMARY KEY,
  "season_number" INTEGER NOT NULL,
  "episode_number" INTEGER,
  "title_id" INTEGER NOT NULL,
  "version_ts" TIMESTAMP NOT NULL
);

--> statement-breakpoint
CREATE TABLE "tmdb"."title_season" (
  "_id" UUID NOT NULL,
  "id" INTEGER PRIMARY KEY,
  "name" TEXT NOT NULL,
  "overview" TEXT,
  "air_date" date,
  "season_number" SMALLINT NOT NULL,
  "poster_path" TEXT,
  "vote_average" NUMERIC NOT NULL,
  "title_id" INTEGER NOT NULL,
  "version_ts" TIMESTAMP NOT NULL
);

--> statement-breakpoint
CREATE INDEX "title_review_title_id_title_kind_version_ts_index" ON "tmdb"."title_review" ("title_id", "title_kind", "version_ts");

--> statement-breakpoint
CREATE VIEW "tmdb"."title_translation_view" AS (
  SELECT
    "title_id",
    "title_kind",
    "version_ts",
    array_remove(array_agg("sq_translations"."translation"), NULL) AS "translations"
  FROM
    (
      SELECT
        "title_id",
        "title_kind",
        "version_ts",
        jsonb_build_object(
          'iso_3166_1',
          "iso_3166_1",
          'iso_639_1',
          "iso_639_1"
        ) || jsonb_object_agg("field"::TEXT, "value") AS "translation"
      FROM
        "tmdb"."title_translation"
      GROUP BY
        "tmdb"."title_translation"."title_id",
        "tmdb"."title_translation"."title_kind",
        "tmdb"."title_translation"."iso_3166_1",
        "tmdb"."title_translation"."iso_639_1",
        "tmdb"."title_translation"."version_ts"
    ) "sq_translations"
  GROUP BY
    "sq_translations"."title_id",
    "sq_translations"."title_kind",
    "sq_translations"."version_ts"
);
