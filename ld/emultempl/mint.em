# This shell script emits a C file. -*- C -*-
#   Copyright 2006, 2007 Free Software Foundation, Inc.
#
# This file is part of the GNU Binutils.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street - Fifth Floor, Boston,
# MA 02110-1301, USA.
#

# This file is sourced from generic.em
#
fragment <<EOF

/* Standard GEMDOS program flags.  */
#define _MINT_F_FASTLOAD      0x01    /* Don't clear heap.  */
#define _MINT_F_ALTLOAD       0x02    /* OK to load in alternate RAM.  */
#define _MINT_F_ALTALLOC      0x04    /* OK to malloc from alt. RAM.  */
#define _MINT_F_BESTFIT       0x08    /* Load with optimal heap size.  */
/* The memory flags are mutually exclusive.  */
#define _MINT_F_MEMPROTECTION 0xf0    /* Masks out protection bits.  */
#define _MINT_F_MEMPRIVATE    0x00    /* Memory is private.  */
#define _MINT_F_MEMGLOBAL     0x10    /* Read/write access to mem allowed.  */
#define _MINT_F_MEMSUPER      0x20    /* Only supervisor access allowed.  */
#define _MINT_F_MEMREADABLE   0x30    /* Any read access OK.  */
#define _MINT_F_SHTEXT        0x800   /* Program's text may be shared */

/* Option flags.  */
static flagword prg_flags = (_MINT_F_FASTLOAD | _MINT_F_ALTLOAD
			     | _MINT_F_ALTALLOC | _MINT_F_MEMPRIVATE);

/* Handle MiNT specific options.  */
static int
gld${EMULATION_NAME}_parse_args (int argc, char** argv)
{
  int prevoptind = optind;
  int prevopterr = opterr;
  int longind;
  int optc;
  int wanterror;
  static int lastoptind = -1;
  unsigned long flag_value;
  char* tail;

#define OPTION_FASTLOAD (300)
#define OPTION_NO_FASTLOAD (OPTION_FASTLOAD + 1)
#define OPTION_FASTRAM (OPTION_NO_FASTLOAD + 1)
#define OPTION_NO_FASTRAM (OPTION_FASTRAM + 1)
#define OPTION_FASTALLOC (OPTION_NO_FASTRAM + 1)
#define OPTION_NO_FASTALLOC (OPTION_FASTALLOC + 1)
#define OPTION_BESTFIT (OPTION_NO_FASTALLOC + 1)
#define OPTION_NO_BESTFIT (OPTION_BESTFIT + 1)
#define OPTION_BASEREL (OPTION_NO_BESTFIT + 1)
#define OPTION_NO_BASEREL (OPTION_BASEREL + 1)
#define OPTION_MEM_PRIVATE (OPTION_NO_BASEREL + 1)
#define OPTION_MEM_GLOBAL (OPTION_MEM_PRIVATE + 1)
#define OPTION_MEM_SUPER (OPTION_MEM_GLOBAL + 1)
#define OPTION_MEM_READONLY (OPTION_MEM_SUPER + 1)
#define OPTION_PRG_FLAGS (OPTION_MEM_READONLY + 1)

  static struct option longopts[] =
  {
    {"mfastload", no_argument, NULL, OPTION_FASTLOAD},
    {"mno-fastload", no_argument, NULL, OPTION_NO_FASTLOAD},
    {"mfastram", no_argument, NULL, OPTION_FASTRAM},
    {"mno-fastram", no_argument, NULL, OPTION_NO_FASTRAM},
    {"maltram", no_argument, NULL, OPTION_FASTRAM},
    {"mno-altram", no_argument, NULL, OPTION_NO_FASTRAM},
    {"mfastalloc", no_argument, NULL, OPTION_FASTALLOC},
    {"mno-fastalloc", no_argument, NULL, OPTION_NO_FASTALLOC},
    {"maltalloc", no_argument, NULL, OPTION_FASTALLOC},
    {"mno-altalloc", no_argument, NULL, OPTION_NO_FASTALLOC},
    {"mbest-fit", no_argument, NULL, OPTION_BESTFIT},
    {"mno-best-fit", no_argument, NULL, OPTION_NO_BESTFIT},
    {"mbaserel", no_argument, NULL, OPTION_BASEREL},
    {"mno-baserel", no_argument, NULL, OPTION_NO_BASEREL},
    {"mshared-text", no_argument, NULL, OPTION_BASEREL},
    {"mno-shared-text", no_argument, NULL, OPTION_NO_BASEREL},
    {"msharable-text", no_argument, NULL, OPTION_BASEREL},
    {"mno-sharable-text", no_argument, NULL, OPTION_NO_BASEREL},
    /* Memory protection bits.  */
    {"mprivate-memory", no_argument, NULL, OPTION_MEM_PRIVATE },
    {"mglobal-memory", no_argument, NULL, OPTION_MEM_GLOBAL},
    {"msuper-memory", no_argument, NULL, OPTION_MEM_SUPER},
    {"mreadable-memory", no_argument, NULL, OPTION_MEM_READONLY},
    {"mreadonly-memory", no_argument, NULL, OPTION_MEM_READONLY},
    {"mprg-flags", required_argument, NULL, OPTION_PRG_FLAGS},
    {NULL, no_argument, NULL, 0}
  };

  if (lastoptind != optind)
    opterr = 0;
  wanterror = opterr;

  lastoptind = optind;

  optc = getopt_long_only (argc, argv, "-", longopts, &longind);
  opterr = prevopterr;

  switch (optc)
  {
    default:
      if (wanterror)
	xexit (1);
      optind = prevoptind;
      return 0;

    case OPTION_FASTLOAD:
      prg_flags |= _MINT_F_FASTLOAD;
      break;

    case OPTION_NO_FASTLOAD:
      prg_flags &= ~_MINT_F_FASTLOAD;
      break;

    case OPTION_FASTRAM:
      prg_flags |= _MINT_F_ALTLOAD;
      break;

    case OPTION_NO_FASTRAM:
      prg_flags &= ~_MINT_F_ALTLOAD;
      break;

    case OPTION_FASTALLOC:
      prg_flags |= _MINT_F_ALTALLOC;
      break;

    case OPTION_NO_FASTALLOC:
      prg_flags &= ~_MINT_F_ALTALLOC;
      break;

    case OPTION_BESTFIT:
      prg_flags |= _MINT_F_BESTFIT;
      break;

    case OPTION_NO_BESTFIT:
      prg_flags &= ~_MINT_F_BESTFIT;
      break;

    case OPTION_BASEREL:
      prg_flags |= _MINT_F_SHTEXT;
      break;

    case OPTION_NO_BASEREL:
      prg_flags &= ~_MINT_F_SHTEXT;
      break;

    case OPTION_MEM_PRIVATE:
      prg_flags &= ~_MINT_F_MEMPROTECTION;
      break;

    case OPTION_MEM_GLOBAL:
      prg_flags &= ~_MINT_F_MEMPROTECTION;
      prg_flags |= _MINT_F_MEMPRIVATE;
      break;

    case OPTION_MEM_SUPER:
      prg_flags &= ~_MINT_F_MEMPROTECTION;
      prg_flags |= _MINT_F_MEMSUPER;
      break;

    case OPTION_MEM_READONLY:
      prg_flags &= ~_MINT_F_MEMPROTECTION;
      prg_flags |= _MINT_F_MEMREADABLE;
      break;

    case OPTION_PRG_FLAGS:
      flag_value = strtoul (optarg, &tail, 0);
      if (*tail != '\0')
	  {
	    einfo ("%P: warning: ignoring invalid program flags %s\n", optarg);
	  }
      else if (flag_value > 0xffffffffUL)
	  {
	    einfo ("%P: warning: ignoring invalid program flags %s (out of range)\n");
	  }
	  else
	  {
		prg_flags = flag_value;
	  }
	  break;

    case 0:  /* A long option that just set a flag.  */
      break;
    }

  return 1;
}

static void
gld${EMULATION_NAME}_finish (void)
{
  if (strcmp (bfd_get_target (output_bfd), "a.out-mintprg") == 0)
    (void) bfd_m68kmint_set_extended_flags (output_bfd, prg_flags);
}

EOF

# Put these extra routines in ld_${EMULATION_NAME}_emulation
#
LDEMUL_PARSE_ARGS=gld${EMULATION_NAME}_parse_args
LDEMUL_FINISH=gld${EMULATION_NAME}_finish
