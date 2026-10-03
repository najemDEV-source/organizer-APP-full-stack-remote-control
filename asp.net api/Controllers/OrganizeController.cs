using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;
using static Microsoft.Extensions.Logging.EventSource.LoggingEventSource;

[ApiController]
[Route("organize")]
public class OrganizeController : ControllerBase
{

    //the type organizer 
    [HttpGet("type")]
    public IActionResult Type([FromQuery] string path)
    {

        string dir = path;
        string enginePath = "smartOrganizer.exe";


        var psi = new ProcessStartInfo
        {
            FileName = enginePath,
            Arguments =$"--extOrganizer {dir}",
            UseShellExecute = true,
            CreateNoWindow = true
        };
        Debug.WriteLine("this is gotten path : " + path);
        Process.Start(psi);

        return Ok(path);
    }


    //the undo function 

    [HttpGet("undo")]
    public IActionResult Undo(string path) {


        string dir = path;
        string enginePath = "smartOrganizer.exe";


        var psi = new ProcessStartInfo
        {
            FileName = enginePath,
            Arguments = $"--undo {dir}",
            UseShellExecute = true,
            CreateNoWindow = true
        };
        Process.Start(psi);
        return Ok("done undo "+path);
    }

    //the smart organizer
    [HttpGet("smart")]
    public IActionResult smartOrganize(string path) {
        string dir = path;
        string enginePath = "smartOrganizer.exe";
            
        var psi = new ProcessStartInfo
        {
            FileName = enginePath,
            Arguments = $"--smartOrganizer {dir}",
            UseShellExecute = true,
            CreateNoWindow = true
        };
        Process.Start(psi);
        return Ok("done smart org " + path);
    }


    //the date organizer
    [HttpGet("date")]
    public IActionResult date(string path)
    {
        string dir = path;
        string enginePath = "smartOrganizer.exe";

        var psi = new ProcessStartInfo
        {
            FileName = enginePath,
            Arguments = $"--dateOrganizer {dir}",
            UseShellExecute = true,
            CreateNoWindow = true
        };
        Process.Start(psi);
        return Ok("done date org " + path);
    }




    //the size organizer : mb / gb lowe high
    [HttpGet("size")]
    public IActionResult sizeOrganizer(string path,string unit,string low,string high) {
        string dir = path;
        string enginePath = "smartOrganizer.exe";

        var psi = new ProcessStartInfo
        {
            FileName = enginePath,
            Arguments = $" --sizeOrganizer {dir} {unit} {low} {high}",
            UseShellExecute = true,
            CreateNoWindow = true
        };
        Process.Start(psi);
        return Ok("done size org " + path);

    }

    //the file genre organizer
    [HttpGet("genre")]
    public IActionResult fileGenre(string path) {
        string dir = path;
        string enginePath = "smartOrganizer.exe";

        var psi = new ProcessStartInfo
        {
            FileName = enginePath,
            Arguments = $"--fileGenre {dir}",
            UseShellExecute = true,
            CreateNoWindow = true
        };
        Process.Start(psi);
        return Ok("done genre org " + path);
    }

    /// <summary>
    /// ////////////////////////////////////    THE GROUPERS /////////////////////////////////////////////////
    /// </summary>


    // 
    [HttpGet("keywordsGrouper")]
    public IActionResult keywordGrouper(string path, [FromQuery]  string[] keywords) {
        string dir = path;
        string enginePath = "smartOrganizer.exe";
        var psi = new ProcessStartInfo
        {
            FileName = enginePath,
            UseShellExecute = true,
            CreateNoWindow = true
        };
        psi.ArgumentList.Add("--keywordsGrouper");
        psi.ArgumentList.Add($"{dir}");
        foreach (string word in keywords) {
            psi.ArgumentList.Add(word);
        }
        Debug.WriteLine("starting keywords now ...");
        Process.Start(psi);
        return Ok("done keyword grouper " + path);

    }

    //group words by date interval
    [HttpGet("dateGrouper")]
    public IActionResult dateGrouper(string path, [FromQuery] string[] keywords) {

        string dir = path;
        string enginePath = "smartOrganizer.exe";
        var psi = new ProcessStartInfo
        {
            FileName = enginePath,
            UseShellExecute = true,
            CreateNoWindow = true
        };
        psi.ArgumentList.Add("--groupByDateInterval");
        psi.ArgumentList.Add($"{dir}");
        foreach (string word in keywords) {
            psi.ArgumentList.Add(word);
        }
     
        Process.Start(psi);
        return Ok("done date interval grouper " + path);
    }


    // the type grouper
    [HttpGet("typeGrouper")]
    public IActionResult typeGrouper(string path, [FromQuery] string[] keywords) {

        string dir = path;
        string enginePath = "smartOrganizer.exe";
        var psi = new ProcessStartInfo
        {
            FileName = enginePath,
            UseShellExecute = true,
            CreateNoWindow = true
        };
        psi.ArgumentList.Add("--packByExt");
        psi.ArgumentList.Add($"{dir}");
        foreach (string word in keywords)
        {
            psi.ArgumentList.Add(word);
        }

        Process.Start(psi);
        return Ok("done date interval grouper " + path);
    }


    [HttpGet("folderGrouper")]
    public IActionResult folderGrouper(string path, [FromQuery]string[] keywords) {
        
        string dir = path;
        string enginePath = "smartOrganizer.exe";
        var psi = new ProcessStartInfo
        {
            FileName = enginePath,
            UseShellExecute = true,
            CreateNoWindow = true
        };
        psi.ArgumentList.Add("--FolderGrouper");
        psi.ArgumentList.Add($"{dir}");
        foreach (string word in keywords)
        {
            psi.ArgumentList.Add(word);
        }

        Process.Start(psi);
        return Ok("done date interval grouper " + path);
    }

    [HttpGet("unpack")]
    public IActionResult unpcackFolder(string path) {
        
        string dir = path;
        string enginePath = "smartOrganizer.exe";
        var psi = new ProcessStartInfo
        {
            FileName = enginePath,
            Arguments=$"--unpackFolder {dir}",
            UseShellExecute = true,
            CreateNoWindow = true
        };
        Process.Start(psi);
        return Ok("done unpacking");


    }
}
