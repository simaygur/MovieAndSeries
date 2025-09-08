﻿namespace MoviesAndSeries.Models.Entities
{
    public class Rating
    {
        public int Id { get; set; }

        public int UserId { get; set; }
        public User User { get; set; }

        public int? SeriesId { get; set; }
        public Series Series { get; set; }

        public int? MovieId { get; set; }
        public Movie Movie { get; set; }

        public int Score { get; set; }
        public string Comment { get; set; }
        public DateTime CommentDate { get; set; }
    }
}
