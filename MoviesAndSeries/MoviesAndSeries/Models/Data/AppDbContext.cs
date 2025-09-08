using Microsoft.EntityFrameworkCore;
using MoviesAndSeries.Models.Entities;
using System.Collections.Generic;
using System.Reflection.Emit;

namespace MoviesAndSeries.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<User> Users { get; set; }
        public DbSet<Movie> Movies { get; set; }
        public DbSet<Series> Series { get; set; }
        public DbSet<Episode> Episodes { get; set; }
        public DbSet<Rating> Ratings { get; set; }
        public DbSet<Favorite> Favorites { get; set; }
        public DbSet<WatchHistory> WatchHistories { get; set; }
        public DbSet<Genre> Genres { get; set; }
        public DbSet<GenreMap> GenreMaps { get; set; }
        public DbSet<Platform> Platforms { get; set; }
        public DbSet<PlatformMap> PlatformMaps { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // İlişkiler (gerekli olanları ekle)
            modelBuilder.Entity<WatchHistory>()
                .HasOne(w => w.User)
                .WithMany(u => u.WatchHistories)
                .HasForeignKey(w => w.UserId);

            modelBuilder.Entity<WatchHistory>()
                .HasOne(w => w.Episode)
                .WithMany(e => e.WatchHistories)
                .HasForeignKey(w => w.EpisodeId);

            modelBuilder.Entity<Favorite>()
                .HasOne(f => f.User)
                .WithMany(u => u.Favorites)
                .HasForeignKey(f => f.UserId);

            modelBuilder.Entity<Favorite>()
                .HasOne(f => f.Movie)
                .WithMany(m => m.Favorites)
                .HasForeignKey(f => f.MovieId);

            modelBuilder.Entity<Favorite>()
                .HasOne(f => f.Series)
                .WithMany(s => s.Favorites)
                .HasForeignKey(f => f.SeriesId);
        }
    }
}
