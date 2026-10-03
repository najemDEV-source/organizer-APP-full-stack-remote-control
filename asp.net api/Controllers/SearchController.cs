using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;
using static Microsoft.Extensions.Logging.EventSource.LoggingEventSource;



namespace organizerAppAPI.Controllers
{
    //test http


    [ApiController]
    [Route("searchFile")]
    public class SearchController : ControllerBase
    {


        //get results file name 
        public string getResultsFileName(string path) {

            string safeName = path
                 .Replace("\\", "")
                 .Replace("/", "")
                 .Replace(":", "")
                 .Replace(" ", "")
                 .ToLower();

            string fileName = $"tempResults_{safeName}.txt";
            return fileName;
        }


        [HttpGet("projector")]
        public IActionResult projector([FromQuery] string path) {
            string enginePath = "smartSearchEngineU.exe";

            var psi = new ProcessStartInfo
            {
                FileName = enginePath,
                Arguments=$"projector {path}",
                UseShellExecute = true,
                CreateNoWindow = true
            };
            Process.Start(psi);
            Thread.Sleep(1000);

            try
            {
                string fullPath = $@"C:\\Users\{Environment.UserName}\ProgramData\projector.json";
                string jsonText = System.IO.File.ReadAllText(fullPath);
                return Ok(new { results = jsonText });
            }
            catch
            {
                return Ok("error loading exitting...");
            }
        }




        [HttpGet("search")]
        public IActionResult Search([FromQuery] string path,[FromQuery] string[] keywords)
        {
            string dir = path;
            string enginePath = "smartSearchEngineU.exe";


            // دمج الكلمات في سلسلة واحدة
            string joinedKeywords = string.Join(" ", keywords);
            var psi = new ProcessStartInfo
            {
                FileName = enginePath,
                Arguments = $"search {dir} {joinedKeywords}",
                UseShellExecute = true,
                CreateNoWindow = true
            };
            Process.Start(psi);
            Thread.Sleep(1000);

            try
            {
                string fullPath = $@"C:\\Users\{Environment.UserName}\ProgramData\{getResultsFileName(path)}";
                var lines = System.IO.File.ReadAllLines(fullPath);
                return Ok(new { results = lines });
            }
            catch {
                return Ok("error loading exitting...");
            }
            
        }

        [HttpGet("validate")]
        public IActionResult validate(string path) {

            string dir = path;
            string enginePath = "smartSearchEngineU.exe";


            var psi = new ProcessStartInfo
            {
                FileName = enginePath,
                Arguments = $"validate {dir}",
                UseShellExecute = true,
                CreateNoWindow = true
            };
            Process.Start(psi);
            return Ok();
        }


        [HttpGet("universal")]
        public IActionResult universalSearch([FromQuery] string[] Keywords) {
            
            string enginePath = "smartSearchEngineU.exe";

            var psi = new ProcessStartInfo
            {
                FileName = enginePath,
                UseShellExecute = true,
                CreateNoWindow = true
            };
            psi.ArgumentList.Add("universalSearch");
            foreach (string word in Keywords) {
                psi.ArgumentList.Add(word);
            }

            Process.Start(psi);
            Thread.Sleep(1000);
            try
            {
                string fullPath = $@"C:\\Users\{Environment.UserName}\ProgramData\tempResults_UNIVERSAL.txt";
                var lines = System.IO.File.ReadAllLines(fullPath);
                return Ok(new { results = lines });
            }
            catch
            {
                return Ok("error loading exitting...");
            }
        }
    
    }


    
}
