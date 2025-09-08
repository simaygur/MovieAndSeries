namespace MoviesAndSeries.Dtos.Rating
{
    public class ListRatingDto
    {
        public int Id { get; set; }
        public int Score { get; set; }
      
        public int UserId { get; set; }

        public string Comment { get; set; }

        public DateTime CommentDate { get; set; }


    }
}
