#!/bin/bash
#
# BSD 3-Clause License
#
# Copyright (c) 2021, Peter Hoskin <pete@hoskin.cc>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Preset cmdline argument variables
encrypt=0
decrypt=0
help=0
verbose=0
debug=0

# Examine cmdline arguments with getopts
while getopts "i:o:u:p:edhxv" arg;
do
	case $arg in
		i) indir=$OPTARG;;
		o) outdir=$OPTARG;;
		e) encrypt=1;;
		d) decrypt=1;;
		u) username=$OPTARG;;
		p) passphrase=$OPTARG;;
		h) help=1;;
		v) verbose=1;;
		x) debug=1;;
	esac
done

# Hello world!
echo "Welcome to Pete's Grand Protector (PGP) - Recursive Edition - LOL!"
echo "We'll recursively encrypt or decrypt files with GPG"

# Print Help If Required
if [ $help -eq 1 ]
then
	echo
	echo "OMG HELP!!!1"
	echo
	echo "Okey, time to read the manual:"
	echo
	echo " -i <directory>"
	echo "    Input directory. Must exist. Required always"
	echo " -o <directory>"
	echo "    Output directory. Must exist. Required always"
	echo
	echo "Encrypt mode:"
	echo " -e"
	echo "    Obvs we want to turn on encrypt mode"
	echo " -u <username>"
	echo "    Username to pass to gpg -u <username>"
	echo "    Maybe read GPG's manual if you don't know what this is"
	echo "    Required always in encrypt mode"
	echo
	echo " Fun facts:"
	echo "  - Contents of the output directory will be overwritten"
	echo "  - I ran out of things to say. Oops!"
	echo
	echo "Decrypt mode:"
	echo " -d"
	echo "    Obvs we want to turn on decrypt mode"
	echo " -p <passphrase file>"
	echo "    Text file that contains your passphrase"
	echo "    This is handed to gpg --passphrase-file <passphrase file>"
	echo "    Maybe read GPG's manual if you don't know what this is"
	echo "    Required always in decrypt mode"
	echo
	echo " Fun facts:"
	echo "  - I coded in a Jedi joke"
	echo "  - GPG is annoying because you cannot turn off the summary of your key"
	echo "  - Contents of the output directory will be overwritten"
	echo "  - If you try to use encrypt mode and decrypt mode, you're an idiet"
	echo
	echo "Other things I have:"
	echo " -h"
	echo "    You're probably surprised by this, but I wrote a manual"
	echo " -v"
	echo "    Turns on verbosity"
	echo " -x"
	echo "    Turns on extra verbosity"
	exit
fi

# Error handling section
## ERRROR ERRROR ERRROR ERRROR ERRROR ERRROR ERRROR 
## ERRROR ERRROR ERRROR ERRROR ERRROR ERRROR ERRROR 
## ERRROR ERRROR ERRROR ERRROR ERRROR ERRROR ERRROR 
## ERRROR ERRROR ERRROR ERRROR ERRROR ERRROR ERRROR 

# Error handling function - print the script name then the supplied text when called, then exit in error
logError() {
	echo "$0: $@"
	exit 1
}

# GPG validation

# Error validate decrypt mode
if [ $decrypt -eq 1 ]
then
	if [ $encrypt -eq 1 ]
	then
		logError "illegal combination -d (decrypt) & -e (encrypt)"
	fi
	if [[ -z $passphrase ]]
	then
		logError "required paramater -p (passphrase file) is missing"
	fi
	if [[ ! -f $passphrase ]]
	then
		logError "$passphrase does not exist"
	fi
fi

# Error validate encrypt mode
if [ $encrypt -eq 1 ]
then
	if [[ -z $username ]]
	then
		logError "required parameter -u (PGP username) is missing"
	fi
fi

# Error validate paths
if [[ -z $indir ]]
then
	logError "required paramater -i is missing - I need an input directory"
fi
if [[ -z $outdir ]]
then
	logError "required paramater -o is missing - I need an output directory"
fi
if [[ ! -d $indir ]]
then
	logError "input directory does not exist - $indir"
fi
if [[ ! -d $outdir ]]
then
	logError "output directory does not exist - $outdir"
fi

# End the Error Handling
## ERRROR ERRROR ERRROR ERRROR ERRROR ERRROR ERRROR 
## ERRROR ERRROR ERRROR ERRROR ERRROR ERRROR ERRROR 
## ERRROR ERRROR ERRROR ERRROR ERRROR ERRROR ERRROR 
## ERRROR ERRROR ERRROR ERRROR ERRROR ERRROR ERRROR

# Convert paths to absolutes
indir=`readlink -f $indir`
outdir=`readlink -f $outdir`
if [ $decrypt -eq 1 ]
then
	passphrase=`readlink -f passphrase`
fi

## MAIN SCRIPT
## MAIN SCRIPT
## MAIN SCRIPT

# PWD Preservation - we need to cd to the indir but lets go back to the pwd at the end
origpwd=`pwd`
cd "$indir"
if [ $debug -eq 1 ]
then
	echo
	echo "PWD       : `pwd`"
fi

# Explain what we're doing
echo 
echo "Input Directory : $indir"
echo "Output Directory: $outdir"

## Encryption Mode
## Encryption Mode
## Encryption Mode
if [ $encrypt -eq 1 ]
then
	echo "Mode            : Encrypt"
	echo

	# Loop around every directory - main loop!
	find . -type d -print0 | while IFS= read -r -d '' inpath;
	do
		# Trim the prefixed . except when we're root
		if [[ ! $inpath = "." ]]
		then
			inpath=`echo $inpath | cut -c3-`
		fi
		# Append / but not if we're in the root folder
		if [[ ! -z $inpath ]]
		then
			inpath=`echo $inpath/`
		fi
		# Replicate the input directory path in the output directory
		outpath=`echo "$outdir/$inpath"`
		
		# Handle verbosity
		if [ $debug -eq 1 ]
		then
			echo "inpath   : $inpath"
			echo "outpath  : $outpath"
		fi
		if [ $verbose -eq 1 ]
		then
			echo "Directory: $inpath"
		fi
		
		# Create the destination directory
		mkdir -p "$outpath"
		
		# Loop around every file in the current directory
		find "$inpath" -maxdepth 1 -type f -print0 | while IFS= read -r -d '' infile;
		do
			# I forgot why this was necessary lol!
			infile=`basename "$infile"`
			
			# Handle verbosity
			if [ $verbose -eq 1 ]
			then
				echo "File     : $infile"
			fi
			if [ $debug -eq 1 ]
			then
				echo "tmpfile  : $inpath$infile.gpg"
				echo "outfile  : $outpath$infile.gpg"
			fi
			
			# Run GPG
			gpg -e --bzip2-compress-level 9 -r $username "$inpath$infile"
			exitcode=$?
			if [ ! $exitcode -eq "0" ]
			then
				logError "GPG failed on $inpath$infile"
			fi
			
			# Move the encrypted file to the destination
			mv "$inpath$infile.gpg" "$outpath$infile.gpg"
			exitcode=$?
			if [ ! $exitcode -eq "0" ]
			then
				logError "mv failed on $inpath$infile.gpg to $outpath$infile.gpg"
			fi
		done
	done
fi


## Decryption Mode
## Decryption Mode
## Decryption Mode
if [ $decrypt -eq 1 ]
then
	echo "Mode            : Decrypt"
	echo

	#  Loop around every directory - main loop!
	find . -type d -print0 | while IFS= read -r -d '' inpath;
	do
		# Trim the prefixed /
		inpath=`echo $inpath | cut -c3-`
		# Append a /
		if [[ ! -z $inpath ]]
		then
			inpath=`echo $inpath/`
		fi
		# Replicate the input directory path in the output directory
		outpath=`echo "$outdir/$inpath"`
		
		# Handle verbosity
		if [ $debug -eq 1 ]
		then
			echo "inpath   : $inpath"
			echo "outpath  : $outpath"
		fi
		if [ $verbose -eq 1 ]
		then
			echo "Directory: $inpath"
		fi
		
		# Create the destination directory
		mkdir -p "$outpath"
		
		# Loop around every file in the current directory
		find "$inpath" -maxdepth 1 -type f -print0 | while IFS= read -r -d '' infile;
		do
			# I forgot why this was necessary lol!
			infile=`basename "$infile"`
			# Trim .gpg from the filename for the output
			outfile=`echo $outpath$infile | sed 's/.\{4\}$//'`
			
			# Handle verbosity
			if [ $verbose -eq 1 ]
			then
				echo "File     : $infile"
			fi
			if [ $debug -eq 1 ]
			then
				echo "tmpfile  : $inpath$infile.gpg"
				echo "outfile  : $outpath$infile.gpg"
			fi
			
			# Like a Jedi, we're using the force - always!
			# If the destination exists, delete it! Otherwise GPG will prompt for y/n input
			if [[ ! -z $outfile ]]
			then
				rm "$outfile"
			fi
			
			# Run GPG
			gpg -d --passphrase-file "$passphrase" -o "$outfile" "$inpath$infile"
			exitcode=$?
			if [ ! $exitcode -eq "0" ]
			then
				logError "GPG failed on $inpath$infile"
			fi
		done
	done
fi

# PWD Preservation - we need to cd to the indir but lets go back to the pwd at the end
cd "$origpwd"
