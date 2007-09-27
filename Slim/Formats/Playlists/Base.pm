package Slim::Formats::Playlists::Base;

# $Id$

# SqueezeCenter Copyright (c) 2001-2007 Logitech.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License, version 2.

use strict;
use FileHandle;
use IO::String;
use Scalar::Util qw(blessed);

use Slim::Music::Info;
use Slim::Utils::Log;
use Slim::Utils::Misc;

sub _updateMetaData {
	my $class    = shift;
	my $entry    = shift;
	my $metadata = shift;

	my $attributes = {};

	# Update title MetaData only if its not a local file with Title information already cached.
	if ($metadata && Slim::Music::Info::isRemoteURL($entry)) {

		my $track = Slim::Schema->rs('Track')->objectForUrl($entry);

		if ((blessed($track) && $track->can('title')) || !blessed($track)) {

			$attributes = $metadata;
		}
	}

	return Slim::Schema->rs('Track')->updateOrCreate({
		'url'        => $entry,
		'attributes' => $attributes,
		'readTags'   => 1,
	});
}

sub _pathForItem {
	my $class = shift;
	my $item  = shift;

	if (Slim::Music::Info::isFileURL($item) && !Slim::Music::Info::isFragment($item)) {
		return Slim::Utils::Misc::pathFromFileURL($item);
	}

	return $item;
}

sub _filehandleFromNameOrString {
	my $class     = shift;
	my $filename  = shift;
	my $outstring = shift;

	my $output;

	if ($filename) {

		$output = FileHandle->new($filename, "w") || do {

			logError("Could't open $filename for writing.");
			return undef;
		};

		# Always write out in UTF-8 with a BOM.
		if ($] > 5.007) {

			binmode($output, ":raw");

			print $output $File::BOM::enc2bom{'utf8'};

			binmode($output, ":encoding(utf8)");
		}

	} else {

		$output = IO::String->new($$outstring);
	}

	return $output;
}

sub playlistEntryIsValid {
	my ($class, $entry, $url) = @_;

	my $caller = (caller(1))[3];

	if (Slim::Music::Info::isRemoteURL($entry) || Slim::Music::Info::isRemoteURL($url)) {

		return 1;
	}

	# Be verbose to the user - this will let them fix their files / playlists.
	if ($entry eq $url) {

		logWarning("Found self-referencing playlist in:\n\t$entry == $url\n\t - skipping!");
		return 0;
	}

	if (!Slim::Music::Info::isFile($entry)) {

		logWarning("$entry found in playlist:\n\t$url doesn't exist on disk - skipping!");
		return 0;
	}

	return 1;
}

1;

__END__
