import { mkdir, writeFile } from 'fs/promises';
import { existsSync } from 'fs';

export class CustomUpdateMechanism {
  public static availableBlocks = [
    {
      name: 'Invoke Sudo',
      description: 'This will invoke sudo',
      command: `sudo -v`,
      recommendedOrder: 0
    },
    {
      name: 'Visual Checkout',
      description: 'This will fetch the most recent changes to your your repo, allow you to choose the branch you want to start work from, then pull the most recent changes for that branch',
      command: `
        git fetch;
        print_separator "🌳 Choose what branch you'd like to work on 🌳";
        git visual-checkout;
        git pull;`,
      recommendedOrder: 1
    },
    {
      name: 'Prune Local Branches',
      description: 'This will remove any local branches that have been deleted on the remote',
      command: `
        print_separator "✂️ Trimming unneeded branches ✂️"
        git gone`,
      recommendedOrder: 2
    },
    {
      name: 'Update / Install Aquarium',
      description: 'This will update Aquarium to the latest version',
      command: `
        print_separator "🐠 Filling Aquarium 🐠";
        ./$CAULDRON_DIR/update/aquarium_update_step.fish`,
      recommendedOrder: 3
    },
    {
      name: 'Packman',
      description: 'This will update your tool / package manager (I.E. If you use ASDF it will update your tool languages, if you use NVM it will update Node, etc.)',
      command: `
        # Make sure we know their preferred node packman
        choose_packman -s

        # Update asdf
        if command -q asdf
            print_separator "📦 Updating asdf 📦"
            ./update/asdf_update_step.fish
        end`,
      recommendedOrder: 4
    },
    {
      name: 'Update System',
      description: 'This will update your system',
      command: `
        print_separator "🆙 Updating your system 🆙"
        gum spin --spinner moon --title "Updating System..." -- fish -c "sudo apt update && sudo apt -y upgrade"`,
      recommendedOrder: 5
    },
    {
      name: 'Update Homebrew',
      description: 'This will update Homebrew, and all of your installed brews',
      command: `
        # Update Homebrew
        print_separator "⚗️ Updating Homebrew ⚗️"
        gum spin --spinner moon --title "Updating System..." -- fish -c "brew update && brew upgrade && brew cleanup && brew doctor"`,
      recommendedOrder: 6
    },
    {
      name: 'Update Yarn/NPM',
      description: 'This will update Yarn/NPM',
      command: `
        print_separator "🧶 Rolling up most recent ball of yarn 🧶"
        gum spin --spinner moon --title "Updating node_modules..." -- fish -c "yarn && yarn up"`,
      recommendedOrder: 7
    },
    {
      name: 'Upgrade Dependencies',
      description: 'This will bring up a visual interface where you can choose which dependencies to upgrade',
      command: `
        print_separator "🚀 Upgrading dependencies 🚀"
        yarn upgrade-interactive`,
      recommendedOrder: 8
    },
  ]

  public selectedBlocks: typeof CustomUpdateMechanism.availableBlocks = []
  public customOrder = false;

  private createUpdateScript() {
    if (!this.customOrder) this.selectedBlocks = this.sortBlocksByRecommendedOrder()
    return this.selectedBlocks.map(block => block.command).join('\n')
  }

  private sortBlocksByRecommendedOrder() {
    return CustomUpdateMechanism.availableBlocks.sort((a, b) => a.recommendedOrder - b.recommendedOrder)
  }

  public async writeToFile() {
    try {
      const cauldron_directory = process.env.CAULDRON_DIR;
      if (!cauldron_directory) throw new Error('CAULDRON_DIR not set')
      // Make sure the `update` directory exists
      if (existsSync(`${cauldron_directory}/update`) === false) await mkdir(`${cauldron_directory}/update`);
      // Write the custom update script to the `update` directory
      await writeFile(`${cauldron_directory}/update/custom-update.fish`, '#!/bin/fish\n' + this.createUpdateScript(), { mode: 0o755 });
    } catch (error) {
      console.error(error)
    }
  }
}
