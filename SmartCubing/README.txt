This is a collection of scramblers which Ingenero Software adapted for our app CubeTimer (https://itunes.apple.com/nz/app/cubetimer/id453618840?mt=8). Most of these are straight, rather horribly coded ports of Javascript scramblers, the origins of which are detailed in each individual file. 
You are free to use this code however you deem fit; it should work without any issues in an iPhone project, and requires only minor adaptations to work on the Mac. While the code itself is questionable, performance has, in our testings, been highly acceptable. Local caching has been implemented in the case of the 3x3 Random-State Scrambler – such code has been left intact for this distribution.
If you do use this code, an acknowledgement would be appreciated but not required. Providing a link to our app in the App Store would also be very much appreciated.

Usage:

CTScrambleManager *scrambleManager = [CTScrambleManager sharedScrambleManager];
NSString *puzzleType = @"3x3"; //Or any other supported puzzle type
BOOL competitionLength = NO; //Whether scrambles for applicable puzzles should be the full length as set out in the WCA regulations.
NSString *scramble = [scrambleManager scrambleForPuzzleType:puzzleType competitionLength:competitionLength];

The code currently supports iOS 5 and higher.

Legal notes:

Copyright (c) 2012, Ingenero Software where applicable.
All rights reserved.
Neither the name of the creator nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.