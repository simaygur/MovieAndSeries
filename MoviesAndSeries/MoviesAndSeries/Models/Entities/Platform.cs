namespace MoviesAndSeries.Models.Entities
{
    public class Platform
    {

        public int Id { get; set; }
        public string Name { get; set; }

        // Navigation
        public ICollection<PlatformMap> PlatformMaps { get; set; }
    }
}
