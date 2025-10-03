using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MoviesAndSeries.Migrations
{
    /// <inheritdoc />
    public partial class ProfileImageNull : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                "ALTER TABLE \"Users\" ALTER COLUMN \"BirthDate\" TYPE timestamp with time zone USING \"BirthDate\"::timestamp with time zone"
            );
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                "ALTER TABLE \"Users\" ALTER COLUMN \"BirthDate\" TYPE text USING \"BirthDate\"::text"
            );
        }
    }
}